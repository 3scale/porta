# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApisControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    FactoryBot.create_list(:backend_api, 2, account: @provider)
    login_provider @provider
  end

  attr_reader :provider

  test '#index' do
    get provider_admin_backend_apis_path
    assert_response :success
    assert_select '#backend_apis tr', count: @provider.backend_apis.count+1
    @provider.backend_apis.each do |backend_api|
      assert_select '#backend_apis td:first-child', text: backend_api.name
    end
  end

  test '#show' do
    backend_api = @provider.backend_apis.last
    get provider_admin_backend_api_path(backend_api)
    assert_response :success
  end

  test '#create' do
    assert_difference @provider.backend_apis.method(:count) do
      backend_api_attributes = { name: 'My Backend API', system_name: 'my-new-backend-api', private_endpoint: 'https://host.com/p' }
      post provider_admin_backend_apis_path(backend_api: backend_api_attributes)
    end
    assert_response :redirect
    assert_equal 'https://host.com:443/p', @provider.backend_apis.last.private_endpoint
  end

  test '#update' do
    backend_api = @provider.backend_apis.last
    assert_equal 'http://api.example.net:80', backend_api.private_endpoint
    put provider_admin_backend_api_path(backend_api, { backend_api: { private_endpoint: 'https://new-endpoint.com/p' } })
    assert_response :redirect
    assert_equal 'https://new-endpoint.com:443/p', backend_api.reload.private_endpoint
  end
end
