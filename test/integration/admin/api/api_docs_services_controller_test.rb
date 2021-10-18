# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApiDocsServicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @token = FactoryBot.create(:access_token, owner: current_account.admin_users.first!, scopes: %w[account_management]).value
    host! current_account.admin_domain
  end

  class MasterAccountTest < Admin::Api::ApiDocsServicesControllerTest
    def test_index_json_saas
      get admin_api_active_docs_path(access_token: @token)
      assert_response :success
    end

    def test_index_json_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_active_docs_path(access_token: @token)
      assert_response :forbidden
    end

    private

    def current_account
      master_account
    end
  end

  class ProviderAccountTest < Admin::Api::ApiDocsServicesControllerTest
    setup do
      @provider = FactoryBot.create(:provider_account)
      @service = @provider.default_service
      @api_docs_service = FactoryBot.create(:api_docs_service, account: @provider, service: nil)
      @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    end

    attr_reader :provider, :service, :api_docs_service
    alias current_account provider

    def test_create_sets_all_attributes
      assert_difference ::ApiDocs::Service.method(:count) do
        post admin_api_active_docs_path(access_token: @token), params: create_params(service_id: service.id, system_name: 'smart_service')
        assert_response :created
      end

      api_docs_service = provider.api_docs_services.last!
      assert_equal 'smart_service', api_docs_service.system_name
      assert_equal service.id, api_docs_service.service_id
      create_params[:api_docs_service].each do |name, value|
        expected_value = %i[published skip_swagger_validations].include?(name) ? (value == '1') : value
        assert_equal expected_value, api_docs_service.public_send(name)
      end
      assert_equal provider.id, api_docs_service.account_id
    end

    def test_update_with_right_params
      put admin_api_active_doc_path(api_docs_service, access_token: @token), params: update_params(service_id: service.id)
      assert_response :success

      api_docs_service.reload
      update_params[:api_docs_service].each do |name, value|
        expected_value = %i[published skip_swagger_validations].include?(name) ? (value == '1') : value
        assert_equal expected_value, api_docs_service.public_send(name)
      end
      assert_equal provider.id, api_docs_service.account_id
    end

    def test_update_can_remove_service
      api_docs_service.update_attribute(:service_id, provider.default_service_id)
      put admin_api_active_doc_path(api_docs_service, access_token: @token), params: update_params(service_id: '')
      assert_response :success
      assert_nil api_docs_service.reload.service_id
    end

    def test_system_name_is_not_updated
      old_system_name = api_docs_service.system_name
      put admin_api_active_doc_path(api_docs_service, access_token: @token), params: update_params(system_name: "#{old_system_name}-2")
      assert_response :success
      assert_equal old_system_name, api_docs_service.reload.system_name
    end

    def test_update_invalid_params
      old_body = api_docs_service.body
      put admin_api_active_doc_path(api_docs_service, format: :json, access_token: @token), params: update_params(body: '{apis: []}')
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'body'), 'JSON Spec is invalid'
      assert_equal old_body, api_docs_service.reload.body
    end

    def test_update_unexistent_service
      put admin_api_active_doc_path(api_docs_service, format: :json, access_token: @token), params: update_params(service_id: Service.last.id + 1)
      assert_response :unprocessable_entity
      assert_equal 'Service not found', JSON.parse(response.body)['error']
    end

    test 'show' do
      get admin_api_active_doc_path(api_docs_service, format: :json, access_token: @token)
      assert_response :success
    end

    test 'show missing service' do
      get admin_api_active_doc_path(id: 'missing', format: :json, access_token: @token)
      assert_response :not_found
    end

    class MemberPermissions < ActionDispatch::IntegrationTest
      setup do
        @provider = FactoryBot.create(:simple_provider)
        @accessible_service = FactoryBot.create(:simple_service, account: provider)
        @forbidden_service = FactoryBot.create(:simple_service, account: provider)
        @accessible_api_docs_service = FactoryBot.create(:api_docs_service, account: provider, service: accessible_service)
        @forbidden_api_docs_service = FactoryBot.create(:api_docs_service, account: provider, service: forbidden_service)
        @member = FactoryBot.create(:member, account: provider, admin_sections: %w[partners plans])
        @access_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw')

        member.member_permission_service_ids = [accessible_service.id]
        member.activate!

        host! provider.admin_domain
      end

      attr_reader :provider, :accessible_service, :forbidden_service, :accessible_api_docs_service, :forbidden_api_docs_service, :member, :access_token

      test 'index' do
        get admin_api_active_docs_path(path_params)
        assert_response :success
        api_docs_services_ids = JSON.parse(response.body)['api_docs'].map { |api_doc| api_doc.dig('api_doc', 'id') }
        assert_equal [accessible_api_docs_service.id], api_docs_services_ids
      end

      test 'read accessible api doc service' do
        get admin_api_active_doc_path(accessible_api_docs_service, **path_params)
        assert_response :success
      end

      test 'read forbidden api doc service' do
        get admin_api_active_doc_path(forbidden_api_docs_service, **path_params)
        assert_response :not_found
      end

      test 'create with forbidden service' do
        post admin_api_active_docs_path(path_params), params: api_doc_params(service_id: forbidden_service.id)
        assert_response :unprocessable_entity
      end

      test 'update to forbidden service' do
        put admin_api_active_doc_path(accessible_api_docs_service, **path_params), params: { service_id: forbidden_service.id }
        assert_response :unprocessable_entity
      end

      test 'read account level service' do
        account_level_api_docs_service = FactoryBot.create(:api_docs_service, account: provider, service: nil)

        get admin_api_active_doc_path(account_level_api_docs_service, **path_params)
        assert_response :success

        get admin_api_active_docs_path(path_params)
        assert_response :success
        api_docs_services_ids = JSON.parse(response.body)['api_docs'].map { |api_doc| api_doc.dig('api_doc', 'id') }
        assert_contains api_docs_services_ids, account_level_api_docs_service.id
      end

      test 'member missing right admin section' do
        member.admin_sections = ['partners']
        member.save!

        get admin_api_active_docs_path(path_params)
        assert_response :forbidden

        get admin_api_active_doc_path(accessible_api_docs_service, **path_params)
        assert_response :forbidden

        account_level_api_docs_service = FactoryBot.create(:api_docs_service, account: provider, service: nil)

        get admin_api_active_doc_path(account_level_api_docs_service, **path_params)
        assert_response :forbidden
      end

      protected

      def path_params
        { access_token: access_token.value, format: :json }
      end

      def api_doc_params(**extra_params)
        {
          api_docs_service: {
            name: 'my api doc spec',
            system_name: 'my-api-doc-spec',
            body: '{"apis": [{"foo": "bar"}], "basePath": "http://example.net"}',
            description: 'This is the spec of my API',
            published: '1',
            skip_swagger_validations: '0'
          }.merge(extra_params)
        }
      end
    end

    private

    def create_params(different_params = {})
      @create_params ||= api_docs_params(different_params)
    end

    def update_params(different_params = {})
      @update_params ||= api_docs_params(different_params).merge({id: api_docs_service.id})
    end

    def api_docs_params(different_params = {})
      { api_docs_service: {
        name: 'update_servone', body: '{"apis": [{"foo": "bar"}], "basePath": "http://example.net"}',
        description: 'updated description', published: '1', skip_swagger_validations: '0'
      }.merge(different_params) }
    end
  end
end
