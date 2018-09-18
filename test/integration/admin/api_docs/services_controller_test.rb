# frozen_string_literal: true

require 'test_helper'

class Admin::ApiDocs::ServicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    login! current_account
  end

  class ProviderLoggedInTest < Admin::ApiDocs::ServicesControllerTest

    test '#create sets the system_name' do
      assert_difference ::ApiDocs::Service.method(:count) do
        post admin_api_docs_services_path(create_params)
        assert_response :redirect
      end
      assert_equal create_params[:api_docs_service][:system_name], api_docs_service.system_name
    end

    private

    def current_account
      @provider ||= FactoryGirl.create(:provider_account)
    end

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

  def create_params
    { api_docs_service: { system_name: 'smart_service', name: 'servone', body: '{"basePath":"http://github.com", "apis":[]}'} }
  end

  def update_params
    { id: api_docs_service.id, api_docs_service: { name: 'update_servone'} }
  end

  def api_docs_service
    current_account.api_docs_services.last!
  end

  def current_account
    master_account
  end

end
