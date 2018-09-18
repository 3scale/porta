require 'test_helper'

class ApicastV2DeploymentServiceTest < ActiveSupport::TestCase

  Service = ApicastV2DeploymentService

  def setup
    @proxy = FactoryGirl.create(:simple_proxy)
  end

  def test_deployment_save_policies
    ThreeScale.config.stubs(onpremises: true)
    raw_policies = [{name: 'policy', version: '1.0.0', enabled: true, configuration: {data: { request: '1', config: '123' }}}]
    policies = [{name: 'policy', version: '1.0.0', configuration: {data: { request: '1', config: '123' }}}]
    @proxy.update_attributes(policies_config: raw_policies.to_json)
    Service.new(@proxy).call(environment: ProxyConfig::ENVIRONMENTS.first)
    assert_match policies.first.to_json, @proxy.proxy_configs.last.content
  end

  def test_call
    environment = ProxyConfig::ENVIRONMENTS.first
    last_config = nil
    new_config  = nil

    assert_difference(@proxy.proxy_configs.method(:count)) do
      ProxyConfig.any_instance.expects(:differs_from?).returns(true)
      assert (last_config = Service.new(@proxy).call(environment: environment))
    end

    assert_no_difference(@proxy.proxy_configs.method(:count)) do
      ProxyConfig.any_instance.expects(:differs_from?).returns(false)
      assert (new_config = Service.new(@proxy).call(environment: environment))
      assert_equal last_config.version, new_config.version
    end

    assert_difference(@proxy.proxy_configs.method(:count)) do
      ProxyConfig.any_instance.expects(:differs_from?).returns(true)
      assert (new_config = Service.new(@proxy).call(environment: environment))
      assert new_config.version > last_config.version
    end
  end
end

