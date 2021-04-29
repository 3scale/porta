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

  test '#index' do
    get provider_admin_backend_apis_path
    assert_response :success
  end

  test '#new' do
    get new_provider_admin_backend_api_path
    assert_response :success
  end

  test '#show' do
    backend_api = @provider.backend_apis.last
    get provider_admin_backend_api_path(backend_api)
    assert_response :success
  end

  test '#create' do
    assert_difference @provider.backend_apis.method(:count) do
      backend_api_attributes = { name: 'My Backend', system_name: 'my-new-backend-api', private_endpoint: 'https://host.com/p' }
      post provider_admin_backend_apis_path, params: { backend_api: backend_api_attributes }
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
    put provider_admin_backend_api_path(backend_api), params: { backend_api: { private_endpoint: 'https://new-endpoint.com/p' } }
    assert_response :redirect
    assert_equal 'https://new-endpoint.com:443/p', backend_api.reload.private_endpoint
  end

  test 'system_name can be created but not updated' do
    post provider_admin_backend_apis_path, params: { backend_api: {name: 'My Backend', system_name: 'first-system-name', private_endpoint: 'https://endpoint.com/p'} }
    backend_api = provider.backend_apis.last!
    assert_equal 'first-system-name', backend_api.system_name

    put provider_admin_backend_api_path(backend_api), params: { backend_api: {name: 'My Backend', system_name: 'my-new-backend-api'} }
    assert_equal 'first-system-name', backend_api.reload.system_name
  end

  test 'delete a backend api without any products will schedule to delete in background' do
    backend_api = @provider.backend_apis.order(:id).second
    backend_api.backend_api_configs.delete_all
    assert_not backend_api.backend_api_configs.any?

    perform_enqueued_jobs(except: SphinxIndexationWorker) do
      delete provider_admin_backend_api_path(backend_api)
      assert_redirected_to provider_admin_dashboard_path
      assert_not BackendApi.exists? backend_api.id
      assert_equal 'Backend will be deleted shortly.', flash[:notice]
    end
  end

  test 'delete a backend api with products shows the correct error message' do
    backend_api = @provider.backend_apis.order(:id).first!
    assert backend_api.backend_api_configs.any?

    perform_enqueued_jobs(except: SphinxIndexationWorker) do
      delete provider_admin_backend_api_path(backend_api)
      assert backend_api.reload.published?
      assert_equal 'cannot be deleted because it is used by at least one Product', flash[:error]
    end
  end

  test 'xss' do
    backend_api = @provider.backend_apis.last
    backend_api.update_column(:description, "<script>alert('XSS')</script>")
    get provider_admin_backend_api_path(backend_api)
    page = Nokogiri::HTML::Document.parse(response.body)
    assert_equal "<script>alert('XSS')</script>", page.xpath("//dt[text() = 'Description']/following-sibling::dd").first.text
  end

  test 'member permissions' do
    backend_api = FactoryBot.create(:backend_api, account: provider)
    member = FactoryBot.create(:member, account: provider)
    member.activate!

    logout! && login!(provider, user: member)

    get new_provider_admin_backend_api_path
    assert_response :forbidden

    backend_api_attributes = { name: 'My Backend', system_name: 'my-new-backend-api', private_endpoint: 'https://host.com/p' }
    post provider_admin_backend_apis_path, params: { backend_api: backend_api_attributes }
    assert_response :forbidden

    get provider_admin_backend_api_path(backend_api)
    assert_response :forbidden

    get edit_provider_admin_backend_api_path(backend_api)
    assert_response :forbidden

    put provider_admin_backend_api_path(backend_api), params: { backend_api: backend_api_attributes.merge(description: 'New desc') }
    assert_response :forbidden

    delete provider_admin_backend_api_path(backend_api)
    assert_response :forbidden

    member.admin_sections = %w[plans]
    member.save!

    get new_provider_admin_backend_api_path
    assert_response :forbidden

    post provider_admin_backend_apis_path, params: { backend_api: backend_api_attributes }
    assert_response :forbidden

    get provider_admin_backend_api_path(backend_api)
    assert_response :success

    get edit_provider_admin_backend_api_path(backend_api)
    assert_response :success

    put provider_admin_backend_api_path(backend_api), params: { backend_api: backend_api_attributes.merge(description: 'New desc') }
    assert_response :redirect

    delete provider_admin_backend_api_path(backend_api)
    assert_response :forbidden
  end
end
