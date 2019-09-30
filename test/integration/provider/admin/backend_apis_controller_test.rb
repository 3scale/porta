# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApisControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @provider = FactoryBot.create(:provider_account)
    FactoryBot.create_list(:backend_api, 2, account: @provider)
    login_provider @provider
  end

  attr_reader :provider

  test '#new' do
    get new_provider_admin_backend_api_path
    assert_response :success
  end

  test '#show' do
    backend_api = @provider.backend_apis.last
    get provider_admin_backend_api_path(backend_api)
    assert_response :success
  end

  test '#show only accessible services' do
    backend_api = @provider.backend_apis.last

    services = FactoryBot.create_list(:simple_service, 3, account: @provider)
    services.each { |service| service.backend_api_configs.create(backend_api: backend_api) }
    accessible_services = services.take(2)
    non_accessible_service = services.last
    non_accessible_service.update_column(:state, 'deleted')

    get provider_admin_backend_api_path(backend_api)
    accessible_services.each { |service| assert_select 'ul.listing#products_using_backend li a', text: service.name }
    assert_select 'ul.listing#products_using_backend li a', text: non_accessible_service.name, count: 0
  end

  test '#create' do
    assert_difference @provider.backend_apis.method(:count) do
      backend_api_attributes = { name: 'My Backend', system_name: 'my-new-backend-api', private_endpoint: 'https://host.com/p' }
      post provider_admin_backend_apis_path(backend_api: backend_api_attributes)
    end
    assert_response :redirect
    assert_equal 'https://host.com:443/p', @provider.backend_apis.last.private_endpoint
  end

  test '#edit' do
    backend_api = @provider.backend_apis.last
    get edit_provider_admin_backend_api_path(backend_api)
    assert_response :success
  end

  test '#update' do
    backend_api = @provider.backend_apis.last
    assert_equal 'http://api.example.net:80', backend_api.private_endpoint
    put provider_admin_backend_api_path(backend_api, { backend_api: { private_endpoint: 'https://new-endpoint.com/p' } })
    assert_response :redirect
    assert_equal 'https://new-endpoint.com:443/p', backend_api.reload.private_endpoint
  end

  test 'system_name can be created but not updated' do
    post provider_admin_backend_apis_path, { backend_api: {name: 'My Backend', system_name: 'first-system-name', private_endpoint: 'https://endpoint.com/p'} }
    backend_api = provider.backend_apis.last!
    assert_equal 'first-system-name', backend_api.system_name

    put provider_admin_backend_api_path(backend_api, { backend_api: {name: 'My Backend', system_name: 'my-new-backend-api'} })
    assert_equal 'first-system-name', backend_api.reload.system_name
  end

  test 'delete a backend api without any products will schedule to delete in background' do
    backend_api = @provider.backend_apis.order(:id).second
    assert_not backend_api.backend_api_configs.any?

    perform_enqueued_jobs do
      delete provider_admin_backend_api_path(backend_api)
      assert_redirected_to provider_admin_dashboard_path
      assert_not BackendApi.exists? backend_api.id
      assert_equal 'Backend will be deleted shortly.', flash[:notice]
    end
  end

  test 'delete a backend api with products shows the correct error message' do
    backend_api = @provider.backend_apis.order(:id).first!
    assert backend_api.backend_api_configs.any?

    perform_enqueued_jobs do
      delete provider_admin_backend_api_path(backend_api)
      assert backend_api.reload.published?
      assert_equal 'cannot be deleted because it is used by at least one Product', flash[:error]
    end
  end
end
