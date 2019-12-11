class Apicast::SandboxProviderConfGenerator < Apicast::SandboxConfGenerator
  attr_accessor :services, :provider_key

  def initialize(provider_id)
    @provider = Provider.find provider_id
    @services = []

    @provider_key = @provider.api_key

    @services = @provider.services
                         .deployed_with_gateway
                         .reject { |service| service.backend_version.oauth? || service.proxy.apicast_configuration_driven? }
                         .map { |service| Apicast::SandboxProxy.service(service) }
                         .freeze
  end

  def lua_file
    "sandbox_proxy_#{@provider.id}"
  end

  def assigns
    super.merge(proxies: @services)
  end

  # parent confs in puppet repo:
  #    modules/openresty/templates/conf/sandboxproxy-nginx.conf.erb
  #and modules/openresty/templates/conf/hostedproxy-nginx.conf.erb
  def emit
    render 'sandbox/provider', {}
  end
end
