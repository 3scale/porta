# frozen_string_literal: true

require 'test_helper'

class Admin::ApiDocs::ServicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    login! current_account
  end

  class ProviderLoggedInTest < Admin::ApiDocs::ServicesControllerTest
    setup do
      @provider = FactoryGirl.create(:provider_account)
      @service = @provider.default_service
      @api_docs_service = @provider.api_docs_services.create!({name: 'name', body: '{"apis": [], "basePath": "http://example.com"}'})
    end

    test '#create sets all the attributes, including the system_name and the service_id' do
      assert_difference ::ApiDocs::Service.method(:count) do
        post admin_api_docs_services_path(create_params(service_id: service.id, system_name: 'smart_service'))
        assert_response :redirect
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

    test '#update with the right params' do
      put admin_api_docs_service_path(api_docs_service), update_params(service_id: service.id)
      assert_response :redirect
      assert_equal 'ActiveDocs Spec was successfully updated.', flash[:notice]

      api_docs_service.reload
      update_params[:api_docs_service].each do |name, value|
        expected_value = %i[published skip_swagger_validations].include?(name) ? (value == '1') : value
        assert_equal expected_value, api_docs_service.public_send(name)
      end
      assert_equal provider.id, api_docs_service.account_id
    end

    def test_update_can_remove_service
      api_docs_service.update_attribute(:service_id, provider.default_service_id)

      put admin_api_docs_service_path(api_docs_service), update_params(service_id: '')
      assert_response :redirect
      assert_equal 'ActiveDocs Spec was successfully updated.', flash[:notice]

      assert_nil api_docs_service.reload.service_id
    end

    def test_system_name_is_not_updated
      old_system_name = api_docs_service.system_name

      put admin_api_docs_service_path(api_docs_service), update_params(system_name: "#{old_system_name}-2")

      assert_response :redirect
      assert_equal old_system_name, api_docs_service.reload.system_name
    end

    def test_update_invalid_params
      old_body = api_docs_service.body
      put admin_api_docs_service_path(api_docs_service), update_params(body: '{apis: []}')
      assert_includes flash[:error], 'JSON Spec is invalid'
      assert_equal old_body, api_docs_service.reload.body
    end

    def test_update_unexistent_service
      put admin_api_docs_service_path(api_docs_service), update_params(service_id: 200)
      assert_includes flash[:error], 'Service not found'
    end

    private

    attr_reader :provider, :service, :api_docs_service
    alias current_account provider

  end

  class MasterLoggedInTest < Admin::ApiDocs::ServicesControllerTest

    test 'Access allowed for master on Saas' do
      get admin_api_docs_services_path
      assert_response :ok

      assert_difference ::ApiDocs::Service.method(:count) do
        post admin_api_docs_services_path(create_params)
        assert_response :redirect
      end

      get admin_api_docs_service_path(id: api_docs_service.id, format: :json)
      assert_response :ok

      get preview_admin_api_docs_service_path(api_docs_service)
      assert_response :ok

      get edit_admin_api_docs_service_path(api_docs_service)
      assert_response :ok

      put toggle_visible_admin_api_docs_service_path(api_docs_service)
      assert_response :redirect
      assert api_docs_service.published?

      put admin_api_docs_service_path(update_params)
      assert_response :redirect
      assert_equal update_params[:api_docs_service][:name], api_docs_service.name

      assert_difference ::ApiDocs::Service.method(:count), -1 do
        delete admin_api_docs_service_path(api_docs_service)
        assert_response :redirect
      end
    end

    test 'Access forbidden for master on-premises' do
      ThreeScale.stubs(master_on_premises?: true)

      get admin_api_docs_services_path
      assert_response :forbidden

      assert_no_difference ::ApiDocs::Service.method(:count) do
        post admin_api_docs_services_path(create_params)
        assert_response :forbidden
      end

      current_account.api_docs_services.create!(create_params[:api_docs_service])

      get admin_api_docs_service_path(id: api_docs_service.id, format: :json)
      assert_response :forbidden

      get preview_admin_api_docs_service_path(api_docs_service)
      assert_response :forbidden

      get edit_admin_api_docs_service_path(api_docs_service)
      assert_response :forbidden

      put toggle_visible_admin_api_docs_service_path(api_docs_service)
      assert_response :forbidden
      refute api_docs_service.published?

      put admin_api_docs_service_path(update_params)
      assert_response :forbidden

      assert_no_difference ::ApiDocs::Service.method(:count) do
        delete admin_api_docs_service_path(api_docs_service)
        assert_response :forbidden
      end
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
      description: 'updated description', published: '0', skip_swagger_validations: '0'
    }.merge(different_params) }
  end

  def api_docs_service
    current_account.api_docs_services.last!
  end

  def current_account
    master_account
  end

end
