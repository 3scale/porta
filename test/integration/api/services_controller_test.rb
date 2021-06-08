# frozen_string_literal: true

require 'test_helper'

class Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = provider.default_service
    login! provider
  end

  attr_reader :provider, :service

  class IndexTest < self
    test 'index page' do
      get admin_services_path
      assert_response :success
    end
  end

  class SettingsTest < self
    test 'settings' do
      get settings_admin_service_path(service)
      assert_response :success
    end

    test 'settings with finance globally denied' do
      provider = master_account
      provider.settings.stubs(globally_denied_switches: [:finance])
      provider.settings.finance.allow

      logout! && login!(provider)
      get settings_admin_service_path(provider.default_service)

      assert_select "input[name='service[buyer_plan_change_permission]'][value=credit_card]", 0
      assert_select "input[name='service[buyer_plan_change_permission]'][value=request_credit_card]", 0
    end

    test 'settings renders the right template and contains the right sections' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)

      get settings_admin_service_path(service)
      assert_response :success
      page = Nokogiri::HTML::Document.parse(response.body)

      assert_template 'api/services/settings'
      section_titles = page.xpath("//fieldset[@class='inputs']/legend").text

      ['Deployment',
       'API Gateway',
       'Authentication',
       'Authentication Settings',
       'API Key (user_key) Basics',
       'Credentials Location',
       'Security',
       'Gateway Response',
       'Authentication Failed Error',
       'Authentication Missing Error',
       'No Match Error',
       'Usage Limit Exceeded Error'].each do |expected_title|
        section_titles.include? expected_title
      end
    end

    test 'update the settings' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      service.update!(deployment_option: 'self_managed')
      service.proxy.oidc_configuration.save!
      previous_oidc_config_id = service.proxy.reload.oidc_configuration.id

      put admin_service_path(service), params: update_params(oidc_id: previous_oidc_config_id)

      assert_equal 'Product information updated.', flash[:notice]

      update_service_params = update_params[:service]
      update_proxy_params = update_service_params.delete(:proxy_attributes)
      oidc_configuration_params = update_proxy_params.delete(:oidc_configuration_attributes)
      expected_notification_settings = update_service_params[:notification_settings].transform_values { |notifications| notifications.map(&:to_i) }
      expected_buyer_plan_change_permission = update_service_params[:buyer_plan_change_permission]
      expected_signup_and_use = update_service_params
                                  .slice(:intentions_required, :buyers_manage_apps, :referrer_filters_required, :custom_keys_enabled, :buyer_can_select_plan)
                                  .transform_values { |value| (value.to_i == 1) }

      service.reload

      assert_equal expected_notification_settings, service.notification_settings
      assert_equal expected_buyer_plan_change_permission, service.buyer_plan_change_permission
      expected_signup_and_use.each { |attr_name, attr_value| assert_equal attr_value, service.public_send(attr_name) }

      proxy = service.proxy
      update_proxy_params.each do |field_name, expected_value|
        assert_equal expected_value, proxy.public_send(field_name)
      end

      oidc_configuration = proxy.oidc_configuration
      oidc_configuration_params.except(:id).each do |field_name, param_value|
        expected_value = param_value == '1'
        assert_equal expected_value, oidc_configuration.public_send(field_name)
      end
      assert_equal previous_oidc_config_id, proxy.reload.oidc_configuration.id
    end

    test 'cannot update OIDC of another proxy' do
      service.proxy.oidc_configuration.save!
      another_oidc_config = FactoryBot.create(:oidc_configuration)
      oidc_params = {oidc_configuration_attributes: {direct_access_grants_enabled: true, id: another_oidc_config.id}}
      assert_no_change of: -> { service.proxy.reload.oidc_configuration.id } do
        put admin_service_path(service), params: { service: { proxy_attributes: oidc_params } }
      end
      assert_response :not_found
    end

    test 'update endpoint and sandbox endpoint with apicast custom url enabled' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)

      ThreeScale.config.stubs(:apicast_custom_url).returns(true)

      proxy = service.proxy
      proxy.update_columns(endpoint: 'http://old-api.example.com:8080',
                           sandbox_endpoint: 'http://old-api.staging.example.com:8080')

      put admin_service_path(service), params: update_params
      proxy.reload
      assert_equal 'Product information updated.', flash[:notice]
      assert_equal 'http://api.example.com:8080', proxy.endpoint
      assert_equal 'http://api.staging.example.com:8080', proxy.sandbox_endpoint
    end

    test 'update endpoint and sandbox endpoint with apicast custom url disabled' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)

      ThreeScale.config.stubs(:apicast_custom_url).returns(false)

      proxy = service.proxy
      proxy.update_columns(endpoint: 'http://old-api.example.com:8080',
                           sandbox_endpoint: 'http://old-api.staging.example.com:8080')

      # hosted apicast
      put admin_service_path(service), params: update_params
      proxy.reload
      assert_equal 'http://old-api.example.com:8080', proxy.endpoint
      assert_equal 'http://old-api.staging.example.com:8080', proxy.sandbox_endpoint

      # self-menaged apicast
      service.update!(deployment_option: 'self_managed')
      put admin_service_path(service), params: update_params
      proxy.reload
      assert_equal 'Product information updated.', flash[:notice]
      assert_equal 'http://api.example.com:8080', proxy.endpoint
      assert_equal 'http://api.staging.example.com:8080', proxy.sandbox_endpoint
    end

    test 'update settings' do
      put admin_service_path(service), params: update_params
      assert_equal 'Product information updated.', flash[:notice]
    end

    test 'update api_backend' do
      proxy = service.proxy
      proxy.api_backend = 'http://old.backend'
      proxy.save!

      Account.any_instance.stubs(:provider_can_use?).returns(true)

      put admin_service_path(service), params: update_params.deep_merge(service: { proxy_attributes: { api_backend: 'https://new.backend' } })
      assert_equal 'http://old.backend:80', proxy.reload.api_backend
    end

    private

    def update_params(oidc_id: nil)
      @update_params ||= { service:
        { intentions_required: '0',
          buyers_manage_apps: '0',
          referrer_filters_required: '1',
          custom_keys_enabled: '1',
          buyer_can_select_plan: '1',
          buyer_plan_change_permission: 'direct',
          notification_settings:
          { web_provider: ['', '50', '100', '300'],
            email_provider: ['', '50', '100', '150'],
            web_buyer: ['', '50', '100', '150'],
            email_buyer: ['', '50', '100', '300']
          },
          proxy_attributes: {
            endpoint: 'http://api.example.com:8080',
            sandbox_endpoint: 'http://api.staging.example.com:8080',
            oidc_issuer_type: 'keycloak',
            oidc_issuer_endpoint: 'http://u:p@localhost:8080/auth/realms/my-realm',
            oidc_configuration_attributes: {
              standard_flow_enabled: '1',
              implicit_flow_enabled: '1',
              service_accounts_enabled: '0',
              direct_access_grants_enabled: '0',
              id: oidc_id
            }
          }
        }
      }
    end
  end

  class BackendApiCreationTest < self
    def setup
      super
      Logic::RollingUpdates.stubs(enabled?: true)
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      @provider.settings.allow_multiple_services!
    end

    test 'should not create the default Backend' do
      assert_no_change of: -> { BackendApi.count } do
        params = {
          service: {
            system_name: 'my_new_product',
            name: 'My new Product',
            description: 'This will act as product'
          }
        }
        post admin_services_path, params: params
      end

      assert_equal 0, Service.last.backend_api_configs.count
    end
  end

  class ServiceCreateTest < self
    test 'create error shows the right flash message' do
      post admin_services_path, params: { service: { name: '' } }
      assert_equal 'Couldn\'t create Product. Check your Plan limits', flash[:error]

      @provider.settings.allow_multiple_services!

      post admin_services_path, params: { service: { name: '' } }
      assert_equal 'Name can\'t be blank', flash[:error]

      post admin_services_path, params: { service: { name: 'example-service', system_name: '###' } }
      assert_equal 'System name invalid. Only ASCII letters, numbers, dashes and underscores are allowed.', flash[:error]
    end
  end

  class ServiceUpdateTest < self
    test 'update' do
      assert_not_equal @service.name, 'Supetramp'
      put admin_service_path(service), params: { service: { name: 'Supetramp' } }
      assert_response :redirect
      assert_equal service.reload.name, 'Supetramp'
    end

    test 'update handles missing referrer' do
      put admin_service_path(service)
      assert_response :bad_request
    end

    test 'not success update' do
      Service.any_instance.stubs(update_attributes: false)
      put admin_service_path(service), params: { service: { name: 'Supetramp' } }
      assert_response :redirect
    end
  end

  class MemberPermissions < self
    def setup
      super

      @member = FactoryBot.create(:member, account: provider)
      member.activate!

      logout! && login!(provider, user: member)
    end

    attr_reader :member

    test 'member missing right permission' do
      get new_admin_service_path
      assert_response :forbidden

      post admin_services_path, params: create_params
      assert_response :forbidden

      get admin_service_path(service)
      assert_response :forbidden

      get edit_admin_service_path(service)
      assert_response :forbidden

      put admin_service_path(service), params: update_params
      assert_response :forbidden

      delete admin_service_path(service)
      assert_response :forbidden
    end

    test 'member with right permission and access to all services' do
      member.admin_sections = %w[plans]
      member.save!

      get new_admin_service_path
      assert_response :forbidden

      post admin_services_path, params: create_params
      assert_response :forbidden

      get admin_service_path(service)
      assert_response :success

      get edit_admin_service_path(service)
      assert_response :success

      put admin_service_path(service), params: update_params
      assert_response :redirect

      delete admin_service_path(service)
      assert_response :forbidden
    end

    test 'member with right permission and restricted access to services' do
      forbidden_service = FactoryBot.create(:simple_service, account: provider)
      member.admin_sections = %w[plans]
      member.member_permission_service_ids = [service.id]
      member.save!

      get new_admin_service_path
      assert_response :forbidden

      post admin_services_path, params: create_params
      assert_response :forbidden

      get admin_service_path(service)
      assert_response :success

      get edit_admin_service_path(service)
      assert_response :success

      put admin_service_path(service), params: update_params
      assert_response :redirect

      get admin_service_path(forbidden_service)
      assert_response :not_found

      get edit_admin_service_path(forbidden_service)
      assert_response :not_found

      put admin_service_path(forbidden_service), params: update_params
      assert_response :not_found

      delete admin_service_path(service)
      assert_response :forbidden
    end

    protected

    def create_params
      { service: { name: 'My API', system_name: 'my-api' } }
    end

    def update_params
      { service: { description: 'New description for my API' } }
    end
  end
end
