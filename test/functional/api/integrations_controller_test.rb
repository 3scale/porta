require 'test_helper'

class Api::IntegrationsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryGirl.create(:provider_account)
    @provider.default_service.service_tokens.create!(value: 'token')

    host! @provider.admin_domain
    login_provider @provider
  end

  test "should not have access" do
    member = FactoryGirl.create(:member)
    @provider.users << member
    host! @provider.admin_domain
    login_as member
    get :edit, service_id: @provider.default_service.id
    assert_response 403
  end


  test 'should have access' do
    rolling_updates_off
    
    member = FactoryGirl.create(:member)
    member.member_permissions.create(admin_section: 'plans')
    @provider.users << member
    host! @provider.admin_domain
    login_as member

    Service.any_instance.stubs(proxiable?: false) # Stub not related with the test, just to skip a render view error

    get :edit, service_id: @provider.default_service.id
    assert_response 200
  end

  test 'put update to deploy to production' do
    host! @provider.admin_domain
    login_provider @provider

    Proxy.any_instance.expects(:deploy_production).once
    patch :update_production, service_id: @provider.default_service.id
    assert_response :redirect
  end

  test 'update should change api bubble state to done' do
    @provider.create_onboarding

    Account.any_instance.expects(:provider_can_use?).returns(false).at_least_once
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)
    Proxy.any_instance.stubs(:deploy).returns(true)

    put :update, proxy: {api_backend: 'http://some-api.example.com:443'}, service_id: @provider.default_service.id
    assert_response :redirect

    assert_equal 'api_done', @provider.reload.onboarding.bubble_api_state
  end

  test 'update production should change deployment bubble state to done' do
    @provider.create_onboarding

    @provider.default_service.proxy.update_column :api_backend, 'http://some-api.example.com'

    put :update_production, proxy: { api_backend: 'http://some-api.example.com:443'}, service_id: @provider.default_service.id
    assert_response :redirect

    assert_equal 'deployment_done', @provider.reload.onboarding.bubble_deployment_state
  end

  test 'download nginx config' do
    get :show, format: :zip, service_id: @provider.default_service.id

    assert_response :success
    assert_equal 'application/zip', response.content_type
    assert_includes response.headers, 'Content-Transfer-Encoding', 'Content-Disposition'
    assert_equal 'attachment; filename="proxy_configs.zip"', response['Content-Disposition']
    assert_equal 'binary', response['Content-Transfer-Encoding']

    Zip::InputStream.open(StringIO.new(response.body)) do |zip|
      assert zip.get_next_entry
    end
  end

  test 'download nginx config should change deployment bubble state to done' do
    @provider.create_onboarding

    get :show, format: :zip, service_id: @provider.default_service.id

    assert_response :success
    assert_equal 'deployment_done', @provider.reload.onboarding.bubble_deployment_state
  end

  test 'cannot update custom public endpoint when using APIcast' do
    Logic::RollingUpdates.stubs(:enabled? => true)
    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    proxy = @provider.default_service.proxy
    proxy.update_column(:endpoint, 'https://endpoint.com:8443')

    # call update_production as that is what APIcast production form calls
    put :update_production, proxy: {endpoint: "http://example.com:80"}, service_id: @provider.default_service.id
    assert_equal 'https://endpoint.com:8443', proxy.reload.endpoint
  end

  test 'update custom public endpoint when deployment method is on premise' do
    Logic::RollingUpdates.stubs(:enabled? => true)
    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    proxy = @provider.default_service.proxy
    proxy.update_column(:endpoint, 'https://endpoint.com:8443')

    # Case where endpoint is allowed to be updated because on premise
    Proxy.any_instance.stubs(self_managed?: true)

    # call update_onpremises_production to update endpoint
    put :update_onpremises_production, proxy: {endpoint: 'http://example.com:80'}, service_id: @provider.default_service.id
    assert_equal 'http://example.com:80', proxy.reload.endpoint
  end

  test 'update custom public endpoint with proxy_pro enabled' do
    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    proxy = @provider.default_service.proxy
    proxy.update_column(:endpoint, 'https://endpoint.com:8443')

    Service.any_instance.expects(:using_proxy_pro?).returns(true).at_least_once
    # call update as proxy_pro updates endpoint through staging section
    put :update, proxy: {endpoint: 'http://example.com:80'}, service_id: @provider.default_service.id
    assert_equal 'http://example.com:80', proxy.reload.endpoint
  end

  test 'create proxy config with proxy_pro enabled' do
    proxy = @provider.default_service.proxy
    proxy.update_column(:apicast_configuration_driven, true)

    Service.any_instance.expects(:using_proxy_pro?).returns(true).at_least_once
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    assert_difference proxy.proxy_configs.method(:count) do
      put :update, proxy: { endpoint: 'http://example.com' }, service_id: @provider.default_service.id
      assert_response :redirect
    end
  end

  test 'cannot update custom public endpoint when configuration-driven APIcast does not support custom URL through ENV' do
    Logic::RollingUpdates.stubs(:enabled? => true)
    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    proxy = @provider.default_service.proxy
    proxy.update_column(:endpoint, 'https://endpoint.com:8443')

    Rails.configuration.three_scale.stubs(apicast_configuration_driven: true)
    Rails.configuration.three_scale.stubs(apicast_custom_url: false)

    # call update_onpremises_production to update production, apicast config driven uses that action
    put :update_onpremises_production, proxy: {endpoint: 'http://example.com:80'}, service_id: @provider.default_service.id
    assert_equal 'https://endpoint.com:8443', proxy.reload.endpoint
  end

  test 'update custom public endpoint when configuration-driven APIcast supports custom URL through ENV' do
    Logic::RollingUpdates.stubs(:enabled? => true)
    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    proxy = @provider.default_service.proxy
    proxy.update_column(:endpoint, 'https://endpoint.com:8443')

    Rails.configuration.three_scale.stubs(apicast_configuration_driven: true)
    Rails.configuration.three_scale.stubs(apicast_custom_url: true)
    Rails.configuration.three_scale.expects(:apicast_custom_url).returns(true).at_least_once

    # call update_onpremises_production to update production, apicast config driven uses that action
    put :update_onpremises_production, proxy: {endpoint: 'http://example.com:80'}, service_id: @provider.default_service.id
    assert_equal 'http://example.com:80', proxy.reload.endpoint
  end

  test 'updating proxy' do
    Logic::RollingUpdates.stubs(:skipped? => true)
    proxy = @provider.default_service.proxy
    hits = proxy.proxy_rules.first!

    attrs = {
      service_id: @provider.default_service.id,
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
        "error_no_match"=>"Nooooo rule matched",
        "api_test_path"=>"/getstatus",
        "policies_config"=>"[{\"name\":\"alaska\",\"version\":\"1\",\"configuration\":{}}]"},
      "deploy"=> 0,
    }

    Proxy.any_instance.stubs(deploy: true)
    ProxyTestService.any_instance.stubs(:disabled?).returns(true)

    put :update, attrs
    assert_response :redirect

    proxy_attributes = attrs["proxy"]
    proxy_attributes.delete("proxy_rules_attributes")

    proxy.reload

    # puts diff(proxy.attributes.slice(*proxy_attributes.keys), proxy_attributes)
    assert_equal proxy.attributes.slice(*proxy_attributes.keys), proxy_attributes

    assert_equal 1, proxy.proxy_rules.count

    known_atts = proxy.proxy_rules.first!.attributes.slice(*five.keys)
    assert_equal five, known_atts
  end

  test 'show' do
    service = @provider.default_service
    config = FactoryGirl.create(:proxy_config, proxy: service.proxy, version: 3, environment: 'sandbox')

    get :show, service_id: service.id

    assert_response :success
    assert_match "Promote v. #{config.version} to Production", response.body
  end

  test 'promote to production' do
    service = @provider.default_service
    service.proxy.update_columns(apicast_configuration_driven: true)

    staging = FactoryGirl.create(:proxy_config, proxy: service.proxy, environment: 'sandbox')

    put :promote_to_production, service_id: service.id

    assert_response :redirect
    production = ProxyConfig.production.last!
    assert_equal production.version, staging.version
    assert_equal production.content, staging.content
  end
end
