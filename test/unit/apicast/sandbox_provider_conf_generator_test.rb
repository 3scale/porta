require 'test_helper'

class Apicast::SandboxProviderConfGeneratorTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryGirl.create(:provider_account)
    @service = FactoryGirl.create(:service, account: @provider)

    @provider.proxies.update_all(apicast_configuration_driven: false)
    @generator = Apicast::SandboxProviderConfGenerator.new(@provider.id)
  end

  def test_lua_file
    assert_equal "sandbox_proxy_#{@provider.id}", @generator.lua_file
  end

  def test_emit
    @service.service_tokens.create!(value: 'some-token')

    assert_equal 2, @generator.services.size
    assert config = @generator.emit
    assert_match "require('lua.system_proxy.sandbox_proxy_#{@provider.id}').access()", config

    server_name = config.scan(/server_name\s+(.+?);/)
    assert_equal 2, server_name.size

    assert_match %{set $#{@service.backend_authentication_type} "#{@service.backend_authentication_value}";}, config
    assert_match %{set $master_provider_key "#{Account.master.provider_key}";}, config
    assert_match 'proxy_set_header Host 127.0.0.1:4001;', config
  end

  def test_emit_oauth
    assert_equal 2, @generator.services.size

    @service.update_attributes!(backend_version: 'oauth')
    generator = Apicast::SandboxProviderConfGenerator.new(@provider.id)
    assert_equal 1, generator.services.size

    @provider.reload.services.update_all(backend_version: 'oauth')
    generator = Apicast::SandboxProviderConfGenerator.new(@provider.id)
    assert_equal 0, generator.services.size
  end

  def test_emit_apicast
    assert_equal 2, @generator.services.size

    @service.update_attributes!(deployment_option: 'plugin_ruby')
    generator = Apicast::SandboxProviderConfGenerator.new(@provider.id)
    assert_equal 1, generator.services.size

    @provider.services.update_all(deployment_option: 'plugin_ruby')
    generator = Apicast::SandboxProviderConfGenerator.new(@provider.id)
    assert_equal 0, generator.services.size
  end

  def test_emit_apicast_configuration_driven
    assert_equal 2, @generator.services.size

    @service.reload.proxy.update_attributes!(apicast_configuration_driven: true)
    generator = Apicast::SandboxProviderConfGenerator.new(@provider.id)
    assert_equal 1, generator.services.size

    @provider.proxies.update_all(apicast_configuration_driven: true)
    generator = Apicast::SandboxProviderConfGenerator.new(@provider.id)
    assert_equal 0, generator.services.size
  end

  class WithoutRollingUpdate < self
    def setup
      Logic::RollingUpdates.stubs(skipped?: true)
      super
      assert_equal :provider_key, @service.backend_authentication_type
    end
  end
end
