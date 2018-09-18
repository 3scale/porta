require 'test_helper'

class Apicast::SandboxProxyConfGeneratorTest < ActiveSupport::TestCase
  def setup
    master = FactoryGirl.build_stubbed(:simple_master)
    master.stubs(provider_key: "master-#{provider_key}")

    provider = FactoryGirl.build_stubbed(:simple_provider)
    provider.stubs(provider_key: provider_key)

    service = FactoryGirl.build_stubbed(:simple_service, account: provider)
    @proxy = FactoryGirl.build_stubbed(:simple_proxy, service: service)

    @generator = Apicast::SandboxProxyConfGenerator.new(@proxy)
  end

  def test_lua_file
    assert_equal "sandbox_service_#{@proxy.service_id}", @generator.lua_file
  end

  def test_emit
    assert @generator.emit
  end

  def provider_key
    'some-provider-key'
  end
end
