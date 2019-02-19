require 'test_helper'

class Admin::Api::Services::ProxiesTest < ActionDispatch::IntegrationTest

  def setup
    @account = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:simple_service, account: @account)

    host! @account.admin_domain
  end

  def test_crud_access_token
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @account, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    # show
    get(admin_api_service_proxy_path(access_token_params))
    assert_response :forbidden
    get(admin_api_service_proxy_path(access_token_params(token.value)))
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_service_proxy_path(access_token_params(token.value)))
    assert_response :success

    # update
    params = access_token_params(token.value).merge(proxy: { endpoint: 'https://alaska.wild' })
    put(admin_api_service_proxy_path(params))
    assert_response :success
  end

  def test_crud_provider_key
    # show
    get(admin_api_service_proxy_path(provider_key_params))
    assert_response :success

    # update
    params = provider_key_params.merge(proxy: { endpoint: 'https://alaska.wild' })
    put(admin_api_service_proxy_path(params))
    assert_response :success
  end

  def test_update
    params = provider_key_params.merge(proxy: { endpoint: 'https://alaska.wild' })

    Proxy.update_all(apicast_configuration_driven: false)
    Proxy.any_instance.expects(:deploy_v2).never
    put(admin_api_service_proxy_path(params))
    assert_response :success

    Proxy.update_all(apicast_configuration_driven: true)
    Proxy.any_instance.expects(:deploy_v2).once
    put(admin_api_service_proxy_path(params))
    assert_response :success
  end

  def test_update_for_service_mesh
    rolling_updates_on
    params = provider_key_params.merge(proxy: { credentials_location: 'headers' })
    @service.update_column :deployment_option, 'service_mesh_istio'

    assert_difference @service.proxy.proxy_configs.production.method(:count), +1 do
      put(admin_api_service_proxy_path(params))
    end
    assert_response :success
  end

  private

  def access_token_params(token = '')
    default_params.merge({ access_token: token })
  end

  def provider_key_params
    default_params.merge({ provider_key: @account.provider_key })
  end

  def default_params
    { service_id: @service.id }
  end
end
