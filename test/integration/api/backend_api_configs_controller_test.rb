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

  test '#new only for backend_apis not used by the product' do
    backend_apis = [backend_api, *FactoryBot.create_list(:backend_api, 2, account: backend_api.account)]

    backend_apis_not_in_use = backend_apis.take(2)
    backend_api_in_use = backend_apis.last
    service.backend_api_configs.create(backend_api: backend_api_in_use)

    get new_admin_service_backend_api_config_path(service)
    backend_apis_not_in_use.each { |backend_api| assert_select 'select#backend_api_config_backend_api_id option[value=?]', backend_api.id }
    assert_select 'select#backend_api_config_backend_api_id option[value=?]', backend_api_in_use.id, count: 0
  end

  test '#new only for accessible backend_apis' do
    backend_apis = [backend_api, *FactoryBot.create_list(:backend_api, 2, account: backend_api.account)]
    accessible_backend_apis = backend_apis.take(2)
    non_accessible_backend_api = backend_apis.last
    non_accessible_backend_api.update_column(:state, 'deleted')

    get new_admin_service_backend_api_config_path(service)
    accessible_backend_apis.each { |backend_api| assert_select 'select#backend_api_config_backend_api_id option[value=?]', backend_api.id }
    assert_select 'select#backend_api_config_backend_api_id option[value=?]', non_accessible_backend_api.id, count: 0
  end

  test '#create' do
    assert_change of: -> { service.backend_api_configs.count }, by: 1 do
      post admin_service_backend_api_configs_path(service), backend_api_config: {
        backend_api_id: backend_api.id,
        path: 'foo'
      }
      assert_redirected_to admin_service_backend_api_configs_path(service)
      assert_equal 'Backend added to Product.', flash[:notice]
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
      assert_equal "Couldn't add Backend to Product", flash[:error]
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
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'whatever')
    get edit_admin_service_backend_api_config_path(service, config)
    assert_response :success
    assert_select 'form.backend_api_config input#backend_api_config_backend_api_id[disabled=disabled][value=?]', backend_api.name
  end

  test '#update' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
    put admin_service_backend_api_config_path(service, config), backend_api_config: { path: 'bar' }
    assert_redirected_to admin_service_backend_api_configs_path(service)
    assert_equal 'Backend usage was updated.', flash[:notice]
    assert_equal 'bar', config.reload.path
  end

  test 'cannot change backend_api' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'whatever')
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
      assert_equal 'The Backend was removed from the Product', flash[:notice]
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
