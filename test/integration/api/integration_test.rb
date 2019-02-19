require 'test_helper'

class IntegrationsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_index
    service = FactoryBot.create(:simple_service, account: @provider)

    get admin_service_integration_path(service_id: service)
    assert_response :success
    assert assigns(:show_presenter)
  end

  def test_promote_to_production_error
    service = FactoryBot.create(:simple_service, account: @provider)

    Proxy.any_instance.expects(:deploy_production).returns(true).once
    patch promote_to_production_admin_service_integration_path(service_id: service)
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert_nil flash[:error]
  end

  def test_promote_to_production_success
    service = FactoryBot.create(:simple_service, account: @provider)

    Proxy.any_instance.expects(:deploy_production).returns(false).once
    patch promote_to_production_admin_service_integration_path(service_id: service)
    assert_response :redirect
    assert_nil flash[:notice]
    assert_not_nil flash[:error]
  end

  def test_update_proxy_rule_position
    Proxy.any_instance.stubs(:deploy).returns(true)
    Proxy.any_instance.stubs(:send_api_test_request!).returns(true)

    service = @provider.services.first
    service.proxy.proxy_rules.destroy_all
    proxy_rule_1 = FactoryBot.create(:proxy_rule, proxy: service.proxy)
    proxy_rule_2 = FactoryBot.create(:proxy_rule, proxy: service.proxy)

    # sending both proxy rules
    assert_not_equal 1, proxy_rule_2.position
    proxy_rules_attributes = {
      proxy_rules_attributes: {
        proxy_rule_1.id => { id: proxy_rule_1.id, position: 2 },
        proxy_rule_2.id => { id: proxy_rule_2.id, position: 1 }
      }
    }
    put admin_service_integration_path(service_id: service), proxy: proxy_rules_attributes
    assert_response :redirect

    proxy_rule_1.reload
    proxy_rule_2.reload
    assert_equal 1, proxy_rule_2.position
    assert_equal 2, proxy_rule_1.position

    # sending just one proxy rule
    proxy_rules_attributes = {
      proxy_rules_attributes: {
        proxy_rule_1.id => { id: proxy_rule_1.id, position: 1 }
      }
    }
    put admin_service_integration_path(service_id: service), proxy: proxy_rules_attributes
    assert_response :redirect

    proxy_rule_1.reload
    proxy_rule_2.reload
    assert_equal 2, proxy_rule_2.position
    assert_equal 1, proxy_rule_1.position

    # creating new proxy rules
    proxy_rules_attributes = {
      proxy_rules_attributes: {
        '1550572218071' => { id: '', http_method: 'PUT', pattern: '/put1', delta: '1', metric_id: proxy_rule_1.metric_id, position: '1' },
        proxy_rule_2.id => { id: proxy_rule_2.id, position: 2 },
        '1550572218070' => { id: '', http_method: 'PUT', pattern: '/put2', delta: '1', metric_id: proxy_rule_1.metric_id, position: '3' },
        proxy_rule_1.id => { id: proxy_rule_1.id, position: 4 }
      }
    }
    put admin_service_integration_path(service_id: service), proxy: proxy_rules_attributes
    assert_response :redirect

    proxy_rule_1.reload
    proxy_rule_2.reload
    assert_equal 1, service.reload.proxy.proxy_rules.find_by_pattern('/put1').position
    assert_equal 2, proxy_rule_2.position
    assert_equal 3, service.reload.proxy.proxy_rules.find_by_pattern('/put2').position
    assert_equal 4, proxy_rule_1.position
  end

  test 'deploy is called when saving proxy info' do
    Account.any_instance.stubs(:provider_can_use?).returns(false)

    Proxy.any_instance.expects(:save_and_deploy).once

    put "/apiconfig/services/#{@provider.services.first.id}/integration", proxy: {api_backend: '1'}
  end

  test 'deploy is never called when saving proxy info for proxy pro users' do
    rolling_updates_on

    Proxy.any_instance.expects(:save_and_deploy).never
    Proxy.any_instance.expects(:update_attributes).once
    ProxyTestService.expects(:new).never
    ProxyTestService.any_instance.expects(:perform).never

    service = @provider.services.default
    service.update_columns(deployment_option: 'self_managed')
    service.proxy.update_columns(apicast_configuration_driven: false)

    put "/apiconfig/services/#{service.id}/integration", proxy: {api_backend: '1'}
  end

  def test_edit
    rolling_updates_off

    service_id = 'no-such-service'
    get "/apiconfig/services/#{service_id}/integration/edit"
    assert_response :not_found

    service = FactoryBot.create(:simple_service, account: @provider)
    get "/apiconfig/services/#{service.id}/integration/edit"
    assert_response :success
  end


  test 'update OIDC Authorization flows' do
    rolling_updates_off
    service = FactoryBot.create(:simple_service, account: @provider)
    ProxyTestService.any_instance.stubs(disabled?: true)
    patch admin_service_integration_path(service_id: service, proxy: {oidc_configuration_attributes: {standard_flow_enabled: false, direct_access_grants_enabled: true}})
    assert_response :redirect

    service.reload
    refute service.proxy.oidc_configuration.standard_flow_enabled
    assert service.proxy.oidc_configuration.direct_access_grants_enabled
  end
end
