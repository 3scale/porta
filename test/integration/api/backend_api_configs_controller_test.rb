# frozen_string_literal: true

require 'test_helper'

class Api::BackendApiConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Logic::RollingUpdates.stubs(enabled?: true)
    Account.any_instance.stubs(:provider_can_use?).returns(true)

    provider = FactoryBot.create(:provider_account)
    @service = provider.default_service
    @backend_api = FactoryBot.create(:backend_api, account: provider)

    login! provider
  end

  attr_reader :service, :backend_api

  test '#index' do
    service.backend_api_configs.create(backend_api: backend_api)
    get admin_service_backend_api_configs_path(service)
    assert_response :success
    assert_select 'table#backend_api_configs tbody tr', count: 2
  end

  test '#new' do
    get new_admin_service_backend_api_config_path(service)
    assert_response :success
  end

  test '#create' do
    assert_change of: -> { service.backend_api_configs.count }, by: 1 do
      post admin_service_backend_api_configs_path(service), backend_api_config: {
        backend_api_id: backend_api.id,
        path: 'foo'
      }
      assert_redirected_to admin_service_backend_api_configs_path(service)
      assert_equal 'Backend API added to product.', flash[:notice]
      assert_equal backend_api, service.backend_api_configs.find_by(path: 'foo').backend_api
    end
  end

  test 'path already taken' do
    service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
    other_backend_api_id = FactoryBot.create(:backend_api, account: service.account).id

    assert_no_change of: -> { service.backend_api_configs.count } do
      post admin_service_backend_api_configs_path(service), backend_api_config: {
        backend_api_id: other_backend_api_id,
        path: 'foo'
      }
      assert_equal "Couldn't add Backend API to product", flash[:error]
      refute service.backend_api_configs.find_by(backend_api_id: other_backend_api_id)
    end
  end

  test 'same account backend_api' do
    other_provider = FactoryBot.create(:simple_provider)
    backend_api.update_column(:account_id, other_provider.id)

    assert_no_change of: -> { service.backend_api_configs.count } do
        post admin_service_backend_api_configs_path(service), backend_api_config: {
        backend_api_id: backend_api.id,
        path: 'foo'
      }
      assert_response :not_found
    end
  end

  test '#edit' do
    config = service.backend_api_configs.create(backend_api: backend_api)
    get edit_admin_service_backend_api_config_path(service, config)
    assert_response :success
    assert_select 'form.backend_api_config select#backend_api_config_backend_api_id[disabled=disabled]'
  end

  test '#update' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
    put admin_service_backend_api_config_path(service, config), backend_api_config: { path: 'bar' }
    assert_redirected_to admin_service_backend_api_configs_path(service)
    assert_equal 'Backend API config was updated.', flash[:notice]
    assert_equal 'bar', config.reload.path
  end

  test 'cannot change backend_api' do
    config = service.backend_api_configs.create(backend_api: backend_api)
    other_backend_api = FactoryBot.create(:backend_api, account: service.account)
    put admin_service_backend_api_config_path(service, config), backend_api_config: { backend_api_id: other_backend_api.id }
    assert_redirected_to admin_service_backend_api_configs_path(service)
    assert_equal backend_api.id, config.reload.backend_api_id
  end

  test '#destroy' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
    assert_change of: -> { service.backend_api_configs.count }, by: -1 do
      delete admin_service_backend_api_config_path(service, config)
      assert_redirected_to admin_service_backend_api_configs_path(service)
      assert_equal 'The Backend API was removed from the product', flash[:notice]
      refute service.backend_api_configs.find_by(path: 'foo')
    end
  end

  test 'permission' do
    Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(false).at_least_once
    get admin_service_backend_api_configs_path(service)
    assert_response :forbidden

    Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(true).at_least_once
    get admin_service_backend_api_configs_path(service)
    assert_response :success
  end
end
