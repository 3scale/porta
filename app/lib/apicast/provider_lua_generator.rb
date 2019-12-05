class Apicast::ProviderLuaGenerator < Apicast::LuaGenerator
  REGEX_LITERAL = /[-\w_]+/
  REGEX_VARIABLE = /\{#{REGEX_LITERAL}\}/

  # @param [Apicast::ProviderSource] source
  def emit(source)
    proxies = Array(source.services).map(&:proxy).select(&:valid?)

    auth_params = proxies.map(&method(:get_auth_params))

    service_objects = proxies.map(&method(:service_object))

    endpoints_and_backends = proxies.map(&method(:service_info))

    stash = {
      auth_params: auth_params,
      provider_key: source.provider_key,
      unique_prefix: source.id,
      endpoints_of_services: endpoints_and_backends,
      service_objects: service_objects
    }

    render template: 'provider_lua', locals: stash
  end

  protected

  # @param [Proxy] proxy
  def service_info(proxy)
    "#{proxy.sandbox_endpoint} #{proxy.api_backend} #{proxy.service_id} #{proxy.hostname_rewrite_for_sandbox}"
  end

  def service_object(proxy)
    OpenStruct.new(
      id: proxy.service_id,
      secret_token: proxy.secret_token,
      error_headers_auth_missing: proxy.error_headers_auth_missing,
      error_status_auth_missing: proxy.error_status_auth_missing,
      error_status_auth_failed: proxy.error_status_auth_failed,
      error_headers_auth_failed: proxy.error_headers_auth_failed,
      error_status_no_match: proxy.error_status_no_match,
      error_headers_no_match: proxy.error_headers_no_match,
      error_no_match: proxy.error_no_match,
      error_auth_failed: proxy.error_auth_failed,
      error_auth_missing: proxy.error_auth_missing,
      backend_version: proxy.service_backend_version,
      proxy_rules: proxy.proxy_rules
    )
  end

  module Helpers
    # TODO: Test when multiple args with the same name (it comes as a table, not as a string)
    def check_querystring_params(params)
      args = params.map do |(key, value)|
        case value
        when REGEX_VARIABLE
          %(args["#{key}"] ~= nil)
        else
          %(args["#{key}"] == '#{value}')
        end
      end
      args.join(' and ').html_safe
    end
  end

  def view
    super.extend(Helpers)
  end

  def get_auth_params(proxy)
    uri = URI.parse(proxy.api_backend.presence || 'http://not-entered-url:80')

    OpenStruct.new(
      params_location: proxy.credentials_location == 'headers' ? 'headers' : 'not_headers',
      proxy_auth_app_id: proxy.auth_app_id,
      proxy_auth_app_key: proxy.auth_app_key,
      proxy_auth_user_key: proxy.auth_user_key,
      service_id: proxy.service_id,
      proxy_backend_scheme: uri.scheme.to_s,
      proxy_backend_domain: uri.host.to_s,
      backend_version: proxy.service_backend_version
    )
  end
end
