module Api::IntegrationsHelper

  def api_test_curl(proxy, production=false)
    credentials = proxy.authentication_params_for_proxy
    credentials_3scale = proxy.authentication_params_for_proxy(original_names: true)
    extheaders = ''
    query = ''

    endpoint = "#{production ? proxy.default_production_endpoint : proxy.sandbox_endpoint}#{proxy.api_test_path}"

    case proxy.credentials_location
    when 'headers'
      credentials.each { |k, v| extheaders += " -H'#{k}: #{v}'" }
    when 'query'
      test_path = proxy.api_test_path
      if test_path
        query = "#{(test_path.index('?') ? '&' : '?')}#{credentials.to_query}"
      else
        query = "?#{credentials.to_query}"
      end
    when 'authorization'
      uri = URI(endpoint)

      uri.user, uri.password = proxy.authorization_credentials

      endpoint = uri.to_s
    end

    content_tag :code,
                id: (production ? 'api-production-curl' : 'api-test-curl'),
                'data-credentials' => credentials_3scale.to_json do
      %(curl "#{endpoint}#{query}" #{extheaders})
    end
  end

  def is_https?(url)
    begin
      uri = URI.parse(url)
      uri.is_a? URI::HTTPS
    rescue URI::InvalidURIError
      false
    end
  end


  def different_from_current?
    true #TODO: implement method
  end

  def currently_deploying?(proxy)
    @deploying
  end

  def deployed?(proxy)
    @ever_deployed_hosted
  end

  def apicast_configuration_driven?
    # this should be driven by a boolean attribute on the service
    @service.proxy.apicast_configuration_driven
  end

  def can_toggle_apicast_version?
    current_account.provider_can_use?(:apicast_v2) && current_account.provider_can_use?(:apicast_v1)
  end

  def apicast_custom_urls?
    # should always return true on prem (deployment option 'hosted') and only return true when self managed in saas (deployment option 'self_managed')
    # so the idea would be to keep this rolling update disabled for saas
    Rails.application.config.three_scale.apicast_custom_url || @service.proxy.self_managed?
  end

  def custom_backend?
    # this should probably be its own config
    Rails.configuration.three_scale.active_docs_proxy_disabled
  end

  def apicast_endpoint_input_hint(service, environment:)
    openshift = Rails.application.config.three_scale.apicast_custom_url && service.proxy.hosted?
    t( "formtastic.hints.proxy.endpoint_apicast_2#{'_openshift' if openshift}_html", environment_name: environment)
  end
end
