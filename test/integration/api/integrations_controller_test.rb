# frozen_string_literal: true

require 'test_helper'

class IntegrationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)

    stub_apicast_registry

    login! provider

    rolling_updates_off
  end

  attr_reader :provider

  test 'member user should have access only if it has admin_section "plans"' do
    Service.any_instance.stubs(proxiable?: false) # Stub not related with the test, just to prevent a render view error

    member = FactoryBot.create(:member, account: provider)
    member.activate!
    login! provider, user: member

    get admin_service_integration_path(service_id: service.id)
    assert_response 403

    member.member_permissions.create!(admin_section: 'plans')
    get admin_service_integration_path(service_id: service.id)
    assert_response 200
  end

  def test_index
    get admin_service_integration_path(service_id: service.id)
    assert_response :success
    assert assigns(:show_presenter)
  end

  def test_promote_to_production_success
    ProxyDeploymentService.any_instance.expects(:deploy_production).returns(true).once
    patch promote_to_production_admin_service_integration_path(service_id: service.id)
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert_nil flash[:error]
  end

  def test_promote_to_production_error
    ProxyDeploymentService.any_instance.expects(:deploy_production).returns(false).once
    patch promote_to_production_admin_service_integration_path(service_id: service.id)
    assert_response :redirect
    assert_nil flash[:notice]
    assert_not_nil flash[:error]
  end

  def test_update
    ProxyDeploymentService.any_instance.stubs(:deploy).returns(true)
    proxy_rule_1 = FactoryBot.create(:proxy_rule, proxy: proxy, last: false)

    refute proxy_rule_1.last
    proxy_rules_attributes = {
      proxy_rules_attributes: {
        proxy_rule_1.id => { id: proxy_rule_1.id, last: true }
      }
    }
    put admin_service_integration_path(service_id: service.id), params: { proxy: proxy_rules_attributes }
    assert_response :redirect
    assert proxy_rule_1.reload.last
  end

  test 'update custom public endpoint with proxy_pro enabled' do
    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    proxy.update_column(:endpoint, 'https://endpoint.com:8443')

    Service.any_instance.expects(:using_proxy_pro?).returns(true).at_least_once
    # call update as proxy_pro updates endpoint through staging section
    put admin_service_integration_path(service_id: service.id), params: { proxy: {endpoint: 'http://example.com:80'} }
    assert_equal 'http://example.com:80', proxy.reload.endpoint
  end

  test 'create proxy config with proxy_pro enabled' do
    FactoryBot.create(:service_token, service: service)
    proxy.update_column(:apicast_configuration_driven, true)

    Service.any_instance.expects(:using_proxy_pro?).returns(true).at_least_once
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    assert_difference proxy.proxy_configs.method(:count) do
      put admin_service_integration_path(service_id: service.id), params: { proxy: {endpoint: 'http://example.com'} }
      assert_response :redirect
    end
  end

  def test_update_proxy_rule_position
    ProxyDeploymentService.any_instance.expects(:deploy_staging_v2).returns(true).times(3)

    proxy.proxy_rules.destroy_all
    proxy_rule_1, proxy_rule_2 = FactoryBot.create_list(:proxy_rule, 2, proxy: proxy)

    # sending both proxy rules
    assert_not_equal 1, proxy_rule_2.position
    proxy_rules_attributes = {
      proxy_rules_attributes: {
        proxy_rule_1.id => { id: proxy_rule_1.id, position: 2 },
        proxy_rule_2.id => { id: proxy_rule_2.id, position: 1 }
      }
    }
    put admin_service_integration_path(service_id: service.id), params: { proxy: proxy_rules_attributes }
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
    put admin_service_integration_path(service_id: service.id), params: { proxy: proxy_rules_attributes }
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
    put admin_service_integration_path(service_id: service.id), params: { proxy: proxy_rules_attributes }
    assert_response :redirect

    proxy_rule_1.reload
    proxy_rule_2.reload
    assert_equal 1, service.reload.proxy.proxy_rules.find_by_pattern('/put1').position
    assert_equal 2, proxy_rule_2.position
    assert_equal 3, service.reload.proxy.proxy_rules.find_by_pattern('/put2').position
    assert_equal 4, proxy_rule_1.position
  end

  test 'deploy is called when saving proxy info' do
    Proxy.any_instance.expects(:save_and_deploy).once

    put admin_service_integration_path(service_id: service.id), params: { proxy: {api_backend: '1'} }
  end

  test 'deploy is never called when saving proxy info for proxy pro users' do
    rolling_updates_on
    Account.any_instance.stubs(:provider_can_use?).with(:proxy_pro).returns(true)

    Proxy.any_instance.expects(:save_and_deploy).never
    Proxy.any_instance.expects(:update_attributes).once
    ProxyTestService.expects(:new).never
    ProxyTestService.any_instance.expects(:perform).never
    Policies::PoliciesListService.expects(:call!)

    service.update_column(:deployment_option, 'self_managed')
    proxy.update_column(:apicast_configuration_driven, false)

    put admin_service_integration_path(service_id: service.id), params: { proxy: {api_backend: '1'} }
  end

  test 'updating proxy' do
    FactoryBot.create(:service_token, service: service)
    rolling_updates_off
    hits = proxy.proxy_rules.first!

    attrs = {
      service_id: service.id,
      "proxy"=>
        {"api_backend"=>"http://bye-world-api.3scale.net:80",
        "oauth_login_url"=>"https://example.com",
        "proxy_rules_attributes"=>
        {hits.id.to_s=>{"_destroy"=>"1", "id"=> hits.id},
         Time.now.to_i.to_s=>
            five = {"http_method"=>"POST",
            "pattern"=>"/five",
            "delta"=> 5,
            "metric_id"=> hits.metric_id,
            }
          },
        "auth_app_id" => "X-FOO",
        "auth_app_key" => "X-BAR",
        "hostname_rewrite"=>"echo-api.3scale.net",
        "secret_token"=>"secret_token",
        "credentials_location"=>"headers",
        "auth_user_key"=>"oauth_user_key",
        "error_status_auth_failed"=> 503,
        "error_headers_auth_failed"=>"text/html; charset=us-ascii",
        "error_auth_failed"=>"ooooh Authentication failed",
        "error_status_auth_missing"=> 503,
        "error_headers_auth_missing"=>"text/html; charset=us-ascii",
        "error_auth_missing"=>"ooooh Authentication parameters missing",
        "error_status_no_match"=>504,
        "error_headers_no_match"=>"text/html; charset=us-ascii",
        "error_status_limits_exceeded"=>499,
        "error_headers_limits_exceeded"=>"text/html; charset=us-ascii",
        "error_limits_exceeded"=>"Limit exceeeeeded",
        "error_no_match"=>"Nooooo rule matched",
        "api_test_path"=>"/getstatus",
        "policies_config"=>"[{\"name\":\"alaska\",\"version\":\"1\",\"configuration\":{}}]"},
      "deploy"=> 0
    }

    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(disabled?: true)

    put admin_service_integration_path(attrs)
    assert_response :redirect

    proxy_attributes = attrs['proxy']
    proxy_attributes.delete('proxy_rules_attributes')
    api_backend = proxy_attributes.delete 'api_backend'
    policies_config = proxy_attributes.delete 'policies_config'
    proxy.reload

    assert_equal proxy.attributes.slice(*proxy_attributes.keys), proxy_attributes
    assert_equal 'http://bye-world-api.3scale.net:80', proxy.api_backend
    assert_includes proxy.policies_config.map(&:to_h), *JSON.parse(policies_config)

    assert_equal 1, proxy.proxy_rules.count

    known_atts = proxy.proxy_rules.first!.attributes.slice(*five.keys)
    assert_equal five, known_atts
  end

  test 'update OIDC Authorization flows' do
    @service = FactoryBot.create(:simple_service, account: provider)
    FactoryBot.create(:service_token, service: service)
    ProxyTestService.any_instance.stubs(disabled?: true)
    proxy.oidc_configuration.save!
    oidc_params = {oidc_configuration_attributes: {standard_flow_enabled: false, direct_access_grants_enabled: true, id: proxy.oidc_configuration.id}}
    assert_no_change of: -> { proxy.reload.oidc_configuration.id } do
      put admin_service_integration_path(service_id: service.id, proxy: oidc_params)
    end
    assert_response :success

    service.reload
    refute proxy.oidc_configuration.standard_flow_enabled
    assert proxy.oidc_configuration.direct_access_grants_enabled
  end

  test 'cannot update OIDC of another proxy' do
    @service = FactoryBot.create(:simple_service, account: provider)
    ProxyTestService.any_instance.stubs(disabled?: true)
    proxy.oidc_configuration.save!
    another_oidc_config = FactoryBot.create(:oidc_configuration)
    oidc_params = {oidc_configuration_attributes: {standard_flow_enabled: false, direct_access_grants_enabled: true, id: another_oidc_config.id}}
    assert_no_change of: -> { proxy.reload.oidc_configuration.id } do
      put admin_service_integration_path(service_id: service.id, proxy: oidc_params)
    end
    assert_response :not_found
  end

  def test_example_curl
    FactoryBot.create(:service_token, service: service)
    FactoryBot.create(:proxy_config, proxy: proxy, environment: 'sandbox')
    Api::IntegrationsShowPresenter.any_instance.expects(:any_sandbox_configs?).returns(true).at_least_once

    Service.any_instance.expects(:oauth?).returns(true).at_least_once
    get admin_service_integration_path(service_id: service.id)
    assert_response :success
    assert_not_match 'Example curl for testing', response.body

    Service.any_instance.expects(:oauth?).returns(false).at_least_once
    get admin_service_integration_path(service_id: service.id)
    assert_response :success
    assert_match 'Example curl for testing', response.body
  end

  test 'show' do
    FactoryBot.create(:service_token, service: service)
    config = FactoryBot.create(:proxy_config, proxy: proxy, version: 3, environment: 'sandbox')

    Account.any_instance.stubs(:provider_can_use?).returns(true)

    get admin_service_integration_path(service_id: service.id)

    assert_response :success
    assert_match "Promote v. #{config.version} to Production APIcast", response.body
  end

  test 'promote to production' do
    FactoryBot.create(:service_token, service: service)
    proxy.update_columns(apicast_configuration_driven: true)

    staging = FactoryBot.create(:proxy_config, proxy: proxy, environment: 'sandbox')

    patch promote_to_production_admin_service_integration_path(service_id: service.id)

    assert_response :redirect
    production = ProxyConfig.production.last!
    assert_equal production.version, staging.version
    assert_equal production.content, staging.content
  end

  private

  def service
    @service ||= provider.default_service
  end

  def proxy
    @proxy ||= service.proxy
  end
end
