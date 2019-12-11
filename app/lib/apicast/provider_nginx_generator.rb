class Apicast::ProviderNginxGenerator < Apicast::ConfGenerator
  Upstream = Struct.new(:id, :name, :host, :port)

  def upstream_service(service)
    proxy = service.proxy
    uri = URI.parse(proxy.api_backend.presence || 'http://not-entered-url:80'.freeze)

    Upstream.new(service.id, service.name, uri.host, uri.port)
  end

  def service_conf(service, provider_key)
    server_name = service.proxy.endpoint.present? ? URI(service.proxy.endpoint).host : '$hostname'.freeze

    OpenStruct.new(
      service_id: service.id,
      listen_port: Rails.env.production? ? 80 : service.proxy.endpoint_port,
      server_name: server_name,
      hostname_rewrite: service.proxy.hostname_rewrite_for_sandbox,
      provider_key: provider_key,
      backend_version: service.backend_version,

      backend_authentication_type: service.backend_authentication_type,
      backend_authentication_value: service.backend_authentication_value,

      lua_file: "nginx_#{service.account_id}".freeze,

      # oauth
      login_url: service.proxy.oauth_login_url
    )
  end

  Service = Struct.new(:id, :backend, :server)

  # @param [Apicast::ProviderSource] source
  def emit(source)
    proxyfiable_services = Array(source.services).select(&:proxiable?)

    provider_key = source.provider_key

    services = proxyfiable_services.map do |service|
      backend = upstream_service(service)
      server = service_conf(service, provider_key)

      Service.new(service.id, backend, server)
    end

    stash = {
      services: services
    }

    render template: 'nginx_proxy_template'.freeze, locals: stash
  end

  def assigns
    config = System::Application.config.three_scale.sandbox_proxy

    {
      timestamp: Time.now.utc.iso8601,
      threescale_endpoint: config.backend_host,
      backend_scheme: config.backend_scheme
    }
  end
end
