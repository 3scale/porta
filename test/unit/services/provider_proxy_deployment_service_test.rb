require 'test_helper'

class ProviderProxyDeploymentServiceTest < ActiveSupport::TestCase

  class_attribute :rolling_updates
  self.rolling_updates = false

  def setup
    Logic::RollingUpdates.stubs(skipped?: !rolling_updates)

    @provider = FactoryBot.create(:provider_account)
    @provider.proxies.update_all(apicast_configuration_driven: false)
    @service = ProviderProxyDeploymentService.new(@provider)

    Logic::RollingUpdates.stubs(skipped?: true)
  end

  def test_deploy_success
    proxy = FactoryBot.create(:proxy, api_test_success: true)

    stub_request(:get, "http://test.proxy/deploy/TEST?provider_id=#{@provider.id}")
        .to_return(status: 200)

    assert_empty @provider.proxy_logs


    assert @service.deploy(proxy)
    assert proxy.deployed_at, 'marks proxy as deployed'
    assert @provider.proxy_configs.present?
    assert @provider.proxy_configs_conf.present?
    assert proxy.errors.empty?, 'no errors'
    assert @provider.proxy_logs.present?
    assert proxy.api_test_success, 'should keep api_test_success'
  end

  def test_deploy_failure
    proxy = FactoryBot.create(:proxy, api_test_success: true)

    stub_request(:get, "http://test.proxy/deploy/TEST?provider_id=#{@provider.id}")
        .to_return(status: 500)

    assert_empty @provider.proxy_logs

    refute @service.deploy(proxy)
    refute proxy.deployed_at, 'does not mark proxy as deployed'

    assert proxy.errors.presence
    refute @provider.proxy_configs.present?, 'empties proxy configs'
    refute @provider.proxy_configs_conf.present?, 'empties proxy configs'
    assert @provider.proxy_logs.present?

    refute proxy.api_test_success, 'should reset api_test_success'
  end

  def test_lua_content
    assert_match "-- provider_key: #{@provider.provider_key}", @service.lua_content
  end

  def test_conf_content
    host = URI(@provider.first_service!.proxy.sandbox_endpoint).host
    assert_match "server_name #{host}", @service.conf_content
  end

  test 'conf_content having services integrated via plugin' do
    FactoryBot.create(:service, account: @provider, deployment_option: 'plugin_ruby')
    deployment_service = ProviderProxyDeploymentService.new(@provider)

    assert_nothing_raised do
      host = URI(@provider.first_service!.proxy.sandbox_endpoint).host
      assert_match "server_name #{host}", deployment_service.conf_content
    end
  end

  ConfContentFailure = Class.new(StandardError)

  def test_conf_content_failure
    ::Apicast::SandboxProviderConfGenerator.any_instance.expects(:emit).raises(ConfContentFailure)

    assert_raise ConfContentFailure do
      @service.deploy(Proxy.new)
    end
  end

  class WithRollingUpdate < ProviderProxyDeploymentServiceTest
    self.rolling_updates = true
  end
end
