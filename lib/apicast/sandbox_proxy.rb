module Apicast
  SandboxProxy = Struct.new(:service, :proxy_endpoint, :api_host, :hostname_rewrite) do
    # @param [Service] service
    def self.service(service)
      proxy = service.proxy
      new(service, proxy.sandbox_endpoint, proxy.api_backend, proxy.hostname_rewrite_for_sandbox)
    end

    def proxy_host
      proxy.try!(:sandbox_host)
    end

    protected :service
    delegate :id, to: :service, prefix: true
    delegate :backend_authentication_type, :backend_authentication_value, to: :service
    delegate :proxy, to: :service
  end
end
