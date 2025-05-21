# frozen_string_literal: true

require 'test_helper'

class Api::BackendUsagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Logic::RollingUpdates.stubs(enabled?: true)
    Account.any_instance.stubs(:provider_can_use?).returns(true)

    @provider = FactoryBot.create(:provider_account)
    @service = provider.default_service
    @backend_api = FactoryBot.create(:backend_api, account: provider)

    login! provider
  end

  attr_reader :provider, :service, :backend_api

  test '#index' do
    service.backend_api_configs.create!(backend_api: backend_api, path: 'whatever')
    get admin_service_backend_usages_path(service)
    assert_response :success
    assert_select 'table[aria-label="Backends table"] tbody tr', count: service.backend_apis.count
  end

  test '#new' do
    get new_admin_service_backend_usage_path(service)
    assert_response :success
  end

  test '#create' do
    assert_change of: -> { service.backend_api_configs.count }, by: 1 do
      backend_api_config_params = { backend_api_id: backend_api.id, path: 'foo' }
      post admin_service_backend_usages_path(service), params: { backend_api_config: backend_api_config_params }
      assert_redirected_to admin_service_backend_usages_path(service)
      assert_equal 'Backend added to Product', flash[:success]
      assert_equal backend_api, service.backend_api_configs.find_by(path: '/foo').backend_api
    end
  end

  test 'path already taken' do
    service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
    other_backend_api_id = FactoryBot.create(:backend_api, account: service.account).id

    assert_no_change of: -> { service.backend_api_configs.count } do
      backend_api_config_params = { backend_api_id: other_backend_api_id, path: 'foo' }
      post admin_service_backend_usages_path(service), params: { backend_api_config: backend_api_config_params }
      assert_equal "Couldn't add Backend to Product", flash[:danger]
      refute service.backend_api_configs.find_by(backend_api_id: other_backend_api_id)
    end
  end

  test 'same account backend_api' do
    other_provider = FactoryBot.create(:simple_provider)
    backend_api.update_column(:account_id, other_provider.id)

    assert_no_change of: -> { service.backend_api_configs.count } do
      backend_api_config_params = { backend_api_id: backend_api.id, path: 'foo' }
      post admin_service_backend_usages_path(service), params: { backend_api_config: backend_api_config_params }
      assert_equal "Couldn't add Backend to Product", flash[:danger]
      assert_response :ok
    end
  end

  test '#edit' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'whatever')
    get edit_admin_service_backend_usage_path(service, config)
    assert_response :success
    assert_select 'form.backend_api_config input#backend_api_config_backend_api_id[readonly=readonly][value=?]', backend_api.name
  end

  test '#update' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
    put admin_service_backend_usage_path(service, config), params: { backend_api_config: { path: 'bar' } }
    assert_redirected_to admin_service_backend_usages_path(service)
    assert_equal 'Backend usage was updated', flash[:success]
    assert_equal '/bar', config.reload.path
  end

  test 'cannot change backend_api' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'whatever')
    other_backend_api = FactoryBot.create(:backend_api, account: service.account)
    put admin_service_backend_usage_path(service, config), params: { backend_api_config: { backend_api_id: other_backend_api.id } }
    assert_redirected_to admin_service_backend_usages_path(service)
    assert_equal backend_api.id, config.reload.backend_api_id
  end

  test '#destroy' do
    config = service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
    assert_change of: -> { service.backend_api_configs.count }, by: -1 do
      delete admin_service_backend_usage_path(service, config)
      assert_redirected_to admin_service_backend_usages_path(service)
      assert_equal 'The Backend was removed from the Product', flash[:success]
      refute service.backend_api_configs.find_by(path: 'foo')
    end
  end

  test 'member user' do
    member = FactoryBot.create(:member,
      account: provider,
      admin_sections: %w[portal finance settings partners monitoring plans policy_registry],
      member_permission_service_ids: [service.id]
    )
    member.activate!

    logout!
    login! provider, user: member

    # a specific service allowed
    get admin_service_backend_usages_path(service)
    assert_response :success

    # no services allowed
    member.update(member_permission_service_ids: [])

    get admin_service_backend_usages_path(service)
    assert_response :not_found

    # a different service allowed
    other_service = FactoryBot.create(:simple_service, account: provider)
    member.update(member_permission_service_ids: [other_service.id])

    get admin_service_backend_usages_path(service)
    assert_response :not_found

    # all services allowed
    member.update(member_permission_service_ids: nil)
    get admin_service_backend_usages_path(service)
    assert_response :success
  end
end
