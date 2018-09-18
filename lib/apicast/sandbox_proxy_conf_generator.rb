class Apicast::SandboxProxyConfGenerator < Apicast::SandboxConfGenerator
  attr_accessor :proxy, :provider_key

  # @param [Proxy] proxy
  def initialize(proxy)
    @provider_key = proxy.provider_key

    @proxy = Apicast::SandboxProxy.new(proxy.service,
                                       proxy.sandbox_endpoint, proxy.api_backend,
                                       proxy.hostname_rewrite_for_sandbox)
  end

  def lua_file
    "sandbox_service_#{@proxy.service_id}"
  end

  # parent confs in puppet repo:
  #    modules/openresty/templates/conf/sandboxproxy-nginx.conf.erb
  #and modules/openresty/templates/conf/hostedproxy-nginx.conf.erb

  def emit
    render 'sandbox/service', proxy: @proxy
  end
end
