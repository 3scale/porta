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

  test '#new' do
    get new_admin_service_backend_api_configs_path(service)
    assert_response :success

    Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(false).at_least_once
    get new_admin_service_backend_api_configs_path(service)
    assert_response :forbidden
  end

  test '#create' do
    assert_change of: -> { service.backend_api_configs.count }, by: 1 do
      post admin_service_backend_api_configs_path(service), backend_api_config: {
        backend_api_id: backend_api.id,
        path: 'foo'
      }
      assert_redirected_to edit_admin_service_integration_path(service)
      assert_equal 'Backend API added to product.', flash[:notice]
      assert_equal backend_api, service.backend_api_configs.find_by(path: 'foo').backend_api
    end
  end

  test '#create with path already taken' do
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
end
