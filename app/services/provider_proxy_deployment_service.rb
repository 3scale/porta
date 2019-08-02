class ProviderProxyDeploymentService
  SUCCESS_MESSAGE = 'Deployed successfully.'.freeze
  FAILURE_MESSAGE = 'Deploy failed.'.freeze

  def self.async_deploy(user, proxy)
    id = SecureRandom.uuid
    ProxyDeploymentWorker.perform_async(id, user.id, proxy.id)
    id
  end

  def initialize(provider)
    @provider = provider
    @lua_generator = Apicast::ProviderLuaGenerator.new
    @source = Apicast::ProviderSource.new(@provider)
    @conf_generator = Apicast::SandboxProviderConfGenerator.new(provider.id)
    @proxy_config = System::Application.config.three_scale.sandbox_proxy
    @sandbox_proxy = Apicast::Sandbox.new(provider, @proxy_config)
  end

  def lua_content
    @lua_generator.emit(@source)
  end

  def conf_content
    @conf_generator.emit
  end

  def deploy(proxy)
    tmp = []
    lua = lua_content

    tmp << @provider.proxy_configs = tmpfile(lua)
    tmp << @provider.proxy_configs_conf = tmpfile(conf_content)

    @provider.save

    if (success = @sandbox_proxy.deploy)
      log(SUCCESS_MESSAGE, lua)

      proxy.update_column(:deployed_at, Time.now)
    else
      proxy.errors.add(:sandbox_endpoint, 'Staging API Gateway deploy failed.')
      log(FAILURE_MESSAGE, lua)

      @provider.update_attributes!(proxy_configs: nil, proxy_configs_conf: nil)
      proxy.update_column(:api_test_success, nil)
    end

    success

  ensure
    tmp.compact.each(&File.method(:unlink))
  end

  protected

  def log(message, lua_file)
    @provider.proxy_logs.create(lua_file: lua_file, status: message)
  end

  def tmpfile(content)
    tmp = Tempfile.new('proxy_deployment_service')
    tmp.write(content)
    tmp.open
    tmp
  end

  def analytics
    ThreeScale::Analytics.current_user
  end
end
