# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicesControllerTest < ActionDispatch::IntegrationTest
  include NPlusOneControl::MinitestHelper
  class MasterHostTest < Admin::Api::ServicesControllerTest
    setup do
      @token = FactoryBot.create(:access_token, owner: master_account.admin_users.first!, scopes: %w[account_management]).plaintext_value
      host! master_account.internal_admin_domain
    end

    test 'create' do
      Account.any_instance.stubs(can_create_service?: true)
      %i[xml json].each do |format|
        requested_name = "example name #{format}"
        requested_description = "example description #{format}"
        assert_difference(master_account.services.method(:count)) do
          post admin_api_services_path(format: format, access_token: @token), params: { name: requested_name, description: requested_description }
          assert_response :created
        end
        service = master_account.services.last
        assert_equal requested_name, service.name
        assert_equal requested_description, service.description
      end
    end

    test 'update' do
      service = master_account.default_service
      %i[xml json].each do |format|
        requested_name = "example name #{format}"
        requested_description = "example description #{format}"
        put admin_api_service_path(service, format: format, access_token: @token), params: { name: requested_name, description: requested_description }
        assert_response :ok
        assert_equal requested_name, service.reload.name
        assert_equal requested_description, service.description
      end
    end

    test 'show' do
      service = master_account.default_service
      %i[xml json].each do |format|
        get admin_api_service_path(service, format: format, access_token: @token)
        assert_response :ok
        assert response.body.include?('deployment_option')
        assert response.body.include?(service.deployment_option)
      end
    end

    test 'index works for SaaS but it is unauthorized for Master On-prem' do
      ThreeScale.stubs(master_on_premises?: false)
      get admin_api_services_path(access_token: @token)
      assert_response :ok

      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_services_path(access_token: @token)
      assert_response :forbidden
    end
  end

  class TenantHostTest < ActionDispatch::IntegrationTest
    setup do
      @provider = FactoryBot.create(:provider_account)
      host! provider.external_admin_domain
      @service = FactoryBot.create(:service, account: provider)
      Account.any_instance.stubs(can_create_service?: true)
      Logic::RollingUpdates.stubs(enabled?: true)
    end

    attr_reader :provider, :service

    test 'index returns 304 when services have not been modified' do
      get admin_api_services_path(access_token: access_token_value, format: :json)
      assert_response :success
      etag = response.header['ETag']
      last_modified = response.header['Last-Modified']

      assert_not_nil etag, 'ETag header should be present'
      assert_not_nil last_modified, 'Last-Modified header should be present'

      headers = { 'HTTP_IF_NONE_MATCH' => etag, 'HTTP_IF_MODIFIED_SINCE' => last_modified }
      assert_number_of_queries(11) do
        get admin_api_services_path(access_token: access_token_value, format: :json), headers: headers
      end
      assert_response :not_modified
    end

    test 'index can be paginated' do
      FactoryBot.create_list(:simple_service, 5, account: provider)
      get admin_api_services_path(access_token: access_token_value, format: :json, per_page: 3, page: 2)
      assert_response :success
      response_service_ids = JSON.parse(response.body)['services'].map { |response_service| response_service.dig('service', 'id') }
      assert_equal provider.accessible_services.order(:id).offset(3).limit(3).select(:id).map(&:id), response_service_ids
    end

    test 'delete with api_key' do
      assert_change(of: -> { service.reload.deleted? }, from: false, to: true) do
        delete admin_api_service_path(service, provider_key: provider.api_key)
        assert_response :ok
      end
    end

    test 'create' do
      assert_difference(provider_services.method(:count)) do
        post admin_api_services_path(access_token: access_token_value, format: :json), params: permitted_params.merge(forbidden_params)
        assert_response :created
      end
      assert_correct_params
    end

    {
      '1' => { buyers_manage_keys: true, mandatory_app_key: true, buyer_key_regenerate_enabled: true },
      '2' => { buyers_manage_keys: false, mandatory_app_key: false, buyer_key_regenerate_enabled: true },
      'oauth' => { buyers_manage_keys: true, mandatory_app_key: true, buyer_key_regenerate_enabled: false },
      'oidc' => { buyers_manage_keys: true, mandatory_app_key: true, buyer_key_regenerate_enabled: false }
    }.each do |backend_version, expected_settings|
      test "create filters key settings for #{backend_version} authentication" do
        Account.any_instance.stubs(:provider_can_use?).returns(true) if %w[oauth oidc].include?(backend_version)

        assert_difference(provider.services.method(:count)) do
          post admin_api_services_path(access_token: access_token_value, format: :json), params: {
            name: 'New service', backend_version: backend_version,
            buyers_manage_keys: false, mandatory_app_key: false, buyer_key_regenerate_enabled: false
          }
          assert_response :created
        end

        created_service = provider.services.order(:id).last!
        assert_equal backend_version == 'oidc' ? 'oauth' : backend_version, created_service.backend_version.to_s
        assert created_service.oidc? if backend_version == 'oidc'
        expected_settings.each do |attribute, expected_value|
          assert_equal expected_value, created_service.public_send(attribute), attribute.to_s
        end
      end
    end

    [false, true].each do |finance_allowed|
      test "create plan change values follow finance availability: #{finance_allowed}" do
        provider.settings.finance.allow if finance_allowed

        %w[credit_card request_credit_card none].each do |value|
          assert_difference(provider.services.method(:count)) do
            post admin_api_services_path(access_token: access_token_value, format: :json), params: {
              name: "Service #{value}", buyer_plan_change_permission: value
            }
            assert_response :created
          end
          created_service = provider.services.order(:id).last!
          expected = finance_allowed ? value : 'request'
          assert_equal expected, created_service.buyer_plan_change_permission
        end
      end

      test "update plan change values follow finance availability: #{finance_allowed}" do
        provider.settings.finance.allow if finance_allowed

        %w[request direct credit_card request_credit_card none].each do |value|
          service.update!(buyer_plan_change_permission: 'direct')
          put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { buyer_plan_change_permission: value }

          assert_response :success
          expected = finance_allowed || %w[request direct].include?(value) ? value : 'direct'
          assert_equal expected, service.reload.buyer_plan_change_permission
        end
      end
    end

    test 'create with provider' do
      assert_difference(provider_services.method(:count)) do
        post admin_api_services_path(provider_key: @provider.provider_key, format: :json), params: permitted_params
        assert_response :created
      end
      assert_correct_params
    end

    test 'create with unauthorize provider key' do
      Account.any_instance.stubs(can_create_service?: false)
      assert_no_difference(provider_services.method(:count)) do
        post admin_api_services_path(provider_key: @provider.provider_key, format: :json), params: permitted_params
        assert_response :forbidden
      end
    end

    test 'create with unauthorize admin user' do
      Account.any_instance.stubs(can_create_service?: false)
      assert_no_difference(provider_services.method(:count)) do
        post admin_api_services_path(access_token: access_token_value, format: :json), params: permitted_params
        assert_response :forbidden
      end
    end

    test 'create with errors in the model' do
      assert_no_difference(provider_services.method(:count)) do
        post admin_api_services_path(access_token: access_token_value, format: :json), params: permitted_params.merge({backend_version: 'fake'})
        assert_response :unprocessable_entity
      end
      assert_contains JSON.parse(response.body).dig('errors', 'backend_version'), 'is not included in the list'
    end

    test 'a member user cannot create a service' do
      member = FactoryBot.create(:member, account: provider)
      member_access_token_value = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw').plaintext_value

      assert_no_difference(provider_services.method(:count)) do
        post admin_api_services_path(access_token: member_access_token_value, format: :json), params: permitted_params
        assert_response :forbidden
      end
    end

    test 'update' do
      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: permitted_params.merge(forbidden_params)
      assert_response :success
      assert_correct_params
    end

    test 'update with errors in the model' do
      old_backend_version = service.backend_version
      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: permitted_params.merge({backend_version: 'fake'})
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'backend_version'), 'is not included in the list'
      assert_equal old_backend_version, service.reload.backend_version
    end

    test 'system_name can be created but not updated' do
      post admin_api_services_path(access_token: access_token_value, format: :json), params: permitted_params.merge({system_name: 'first-system-name'})
      service = provider_services.last!
      assert_equal 'first-system-name', service.system_name

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: permitted_params.merge(forbidden_params).merge({system_name: 'updated-system-name'})
      assert_equal 'first-system-name', service.reload.system_name
    end

    test 'the state cannot be created or updated through the attribute' do
      post admin_api_services_path(access_token: access_token_value, format: :json), params: permitted_params.merge({state: 'published'})
      service = provider_services.last!
      assert_not_equal 'published', service.state

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: permitted_params.merge({state: 'published'})
      assert_not_equal 'published', service.reload.state
    end

    test 'the state can be created and updated through the state event of the action machine' do
      post admin_api_services_path(access_token: access_token_value, format: :json), params: permitted_params.merge({state_event: 'publish'})
      service = provider_services.last!
      assert_equal 'published', service.state

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: permitted_params.merge({state_event: 'publish'})
      assert_equal 'published', service.reload.state
    end

    private

    def assert_correct_params
      service = provider_services.last!
      permitted_params.each do |attribute_name, param_value|
        assert check_equality_value(attribute_name, service.public_send(attribute_name), param_value), "#{attribute_name} does not have the expected value of #{param_value}"
      end
      forbidden_params.each do |attribute_name, param_value|
        assert_not check_equality_value(attribute_name, service.public_send(attribute_name), param_value), "#{attribute_name} should not have the value of #{param_value}"
      end
    end

    def check_equality_value(attribute_name, attribute_value, param_value)
      if attribute_name == :notification_settings
        return false if !attribute_value.is_a?(Hash) || (attribute_value.keys.length != param_value.keys.length)

        attribute_value.each do |name_notification_setting, values|
          return false if values.map(&:to_i) != param_value[name_notification_setting].map(&:to_i)
        end

        true
      else
        param_value == attribute_value
      end
    end

    test 'accepts key settings for existing v2 service without submitting backend_version' do
      service.update_columns(backend_version: '2', buyers_manage_keys: true, mandatory_app_key: false)

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { buyers_manage_keys: false, mandatory_app_key: true }

      assert_response :success
      assert_not service.reload.buyers_manage_keys
      assert service.mandatory_app_key
    end

    test 'accepts key settings when switching to v2 in the same request' do
      service.update_columns(backend_version: '1', buyers_manage_keys: true, mandatory_app_key: false)

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { backend_version: '2', buyers_manage_keys: false, mandatory_app_key: true }

      assert_response :success
      assert_equal '2', service.reload.backend_version.to_s
      assert_not service.buyers_manage_keys
      assert service.mandatory_app_key
    end

    test 'ignores key settings when switching away from v2 in the same request' do
      service.update_columns(backend_version: '2', buyers_manage_keys: true, mandatory_app_key: false)

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { backend_version: '1', buyers_manage_keys: false, mandatory_app_key: true }

      assert_response :success
      assert_equal '1', service.reload.backend_version.to_s
      assert service.buyers_manage_keys
      assert_not service.mandatory_app_key
    end

    test 'accepts key regeneration when switching to oauth in the same request' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      service.update_columns(backend_version: '2', buyer_key_regenerate_enabled: true)

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { backend_version: 'oauth', buyer_key_regenerate_enabled: false }

      assert_response :success
      assert_equal 'oauth', service.reload.backend_version.to_s
      assert_not service.buyer_key_regenerate_enabled
    end

    test 'accepts key regeneration when switching to OIDC in the same request' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      service.update_columns(backend_version: '2', buyer_key_regenerate_enabled: true)

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: {
        backend_version: 'oidc', buyer_key_regenerate_enabled: false
      }

      assert_response :success
      assert_equal 'oauth', service.reload.backend_version.to_s
      assert service.oidc?
      assert_not service.buyer_key_regenerate_enabled
    end

    test 'ignores key regeneration when switching away from oauth in the same request' do
      service.update_columns(backend_version: 'oauth', buyer_key_regenerate_enabled: true)

      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { backend_version: '2', buyer_key_regenerate_enabled: false }

      assert_response :success
      assert_equal '2', service.reload.backend_version.to_s
      assert service.buyer_key_regenerate_enabled
    end

    test 'rejects buyers_manage_keys when backend_version is not v2' do
      assert_equal '1', service.backend_version.to_s
      original = service.buyers_manage_keys
      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { buyers_manage_keys: !original }
      assert_response :success
      assert_equal original, service.reload.buyers_manage_keys
    end

    test 'rejects buyer_key_regenerate_enabled when backend is not oauth' do
      service.update_column(:backend_version, '2')
      original = service.buyer_key_regenerate_enabled
      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { buyer_key_regenerate_enabled: !original }
      assert_response :success
      assert_equal original, service.reload.buyer_key_regenerate_enabled
    end

    test 'accepts buyer_key_regenerate_enabled when backend is oauth' do
      service.update_column(:backend_version, 'oauth')
      put admin_api_service_path(service, access_token: access_token_value, format: :json), params: { buyer_key_regenerate_enabled: false }
      assert_response :success
      assert_not service.reload.buyer_key_regenerate_enabled
    end

    def permitted_params
      @permitted_params ||= {
        name: 'the-name',
        description: 'New description',
        support_email: 'support@example.com',
        deployment_option: 'hosted',
        backend_version: '2',
        buyers_manage_keys: false,
        mandatory_app_key: false,
        intentions_required: true,
        buyers_manage_apps: false,
        referrer_filters_required: true,
        custom_keys_enabled: false,
        buyer_can_select_plan: true,
        txt_support: 'text for txt support',
        terms: 'these are our terms',
        buyer_plan_change_permission: 'direct',
        notification_settings: {
          web_provider:   ['', '50', '100', '100'],
          email_provider: ['', '50', '100', '150'],
          web_buyer:      ['', '50', '100', '200'],
          email_buyer:    ['', '50', '100', '300']
        }
      }
    end

    def forbidden_params
      @forbidden_params ||= {
        created_at: 1.day.from_now,
        updated_at: 1.day.from_now,
        kubernetes_service_link: '/api/v1/namespaces/example-project/services/example-api',
        account_id: provider.id + 1,
        tenant_id:  provider.id + 1,
        default_application_plan_id: -1,
        default_service_plan_id: -1,
        logo_file_name: 'example',
        logo_content_type: 'png',
        logo_file_size: 1
      }
    end

    def access_token_value
      @access_token_value ||= FactoryBot.create(:access_token, owner: provider.admin_users.first!, scopes: %w[account_management], permission: 'rw').plaintext_value
    end

    def provider_services
      scope = provider.services
      System::Database.postgres? ? scope.order(:id) : scope
    end
  end
end
