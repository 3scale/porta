# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApiDocsServicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    login! current_account
  end

  class MasterAccountTest < Admin::Api::ApiDocsServicesControllerTest
    def test_index_json_saas
      get admin_api_active_docs_path
      assert_response :success
    end

    def test_index_json_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_active_docs_path
      assert_response :forbidden
    end

    private

    def current_account
      master_account
    end
  end

  class ProviderAccountTest < Admin::Api::ApiDocsServicesControllerTest
    setup do
      @provider = FactoryGirl.create(:provider_account)
      @service = @provider.default_service
      @api_docs_service = @provider.api_docs_services.create!({name: 'name', body: '{"apis": [], "basePath": "http://example.com"}'})
    end

    attr_reader :provider, :service, :api_docs_service
    alias current_account provider

    def test_create_sets_all_attributes
      assert_difference ::ApiDocs::Service.method(:count) do
        post admin_api_active_docs_path(create_params(service_id: service.id, system_name: 'smart_service'))
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
      put admin_api_active_doc_path(api_docs_service), update_params(service_id: service.id)
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
      put admin_api_active_doc_path(api_docs_service), update_params(service_id: '')
      assert_response :success
      assert_nil api_docs_service.reload.service_id
    end

    def test_system_name_is_not_updated
      old_system_name = api_docs_service.system_name
      put admin_api_active_doc_path(api_docs_service), update_params(system_name: "#{old_system_name}-2")
      assert_response :success
      assert_equal old_system_name, api_docs_service.reload.system_name
    end

    def test_update_invalid_params
      old_body = api_docs_service.body
      put admin_api_active_doc_path(api_docs_service, format: :json), update_params(body: '{apis: []}')
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'body'), 'JSON Spec is invalid'
      assert_equal old_body, api_docs_service.reload.body
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
