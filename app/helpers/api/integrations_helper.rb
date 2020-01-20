module Api::IntegrationsHelper

  class CurlCommandBuilder
    def initialize(proxy)
      @proxy = proxy
    end

    attr_reader :proxy

    def command
      return if base_endpoint.blank?

      credentials = proxy.authentication_params_for_proxy
      extheaders = ''

      uri = Addressable::URI.parse(base_endpoint)
      uri.path, uri.query = path_and_query

      case proxy.credentials_location
      when 'headers'
        credentials.each { |k, v| extheaders += " -H'#{k}: #{v}'" }
      when 'query'
        uri.query_values = (uri.query_values || {}).merge(credentials)
      when 'authorization'
        uri.user, uri.password = proxy.authorization_credentials
      end

      "curl \"#{uri}\" #{extheaders}"
    end

    def base_endpoint
      raise NoMethodError, __method__
    end

    def path_and_query
      return api_test_path_and_query unless apiap?

      proxy_rules = proxy.proxy_rules
      proxy_rules.any? ? proxy_rules.first[:pattern] : '/'
    end

    def api_test_path_and_query
      uri = URI.parse(proxy.api_test_path)
      [uri.path, uri.query]
    end

    def apiap?
      proxy.provider_can_use?(:api_as_product)
    end

    class Staging < self
      def base_endpoint
        proxy.sandbox_endpoint
      end
    end

    class Production < self
      def base_endpoint
        proxy.default_production_endpoint
      end
    end

    # It quacks like a Proxy but it's actually a json proxy config
    class ProxyFromConfig
      def initialize(config)
        @config = config
      end

      attr_reader :config

      delegate :sandbox_endpoint, :credentials_location, :api_test_path, :proxy_rules, to: :proxy

      def default_production_endpoint
        proxy.endpoint
      end

      def authentication_params_for_proxy(opts = {})
        params = service.plugin_authentication_params
        keys_to_proxy_args = { app_key: :auth_app_key, app_id: :auth_app_id, user_key: :auth_user_key }
        params.keys.map do |key|
          param_name = opts[:original_names] ? key.to_s : proxy.send(keys_to_proxy_args[key])
          [param_name, params[key]]
        end.to_h
      end

      def authorization_credentials
        params = authentication_params_for_proxy.symbolize_keys
        params.values_at(:user_key).compact.presence || params.values_at(:app_id, :app_key)
      end

      delegate :provider_can_use?, to: 'service.account'

      protected

      def proxy
        @proxy ||= ActiveSupport::OrderedOptions.new.merge(config[:proxy])
      end

      def service
        @service ||= Service.find(proxy.service_id)
      end
    end
  end

  def api_test_curl(proxy, production = false, config_based: false)
    method_sym = config_based ? :config_based_test_curl_command : :test_curl_command
    command = public_send(method_sym, proxy, environment: production ? :production : :staging)
    credentials = proxy.authentication_params_for_proxy(original_names: true)
    tag_id = production ? 'api-production-curl' : 'api-test-curl'
    content_tag :code, id: tag_id, 'data-credentials' => credentials.to_json do
      command
    end
  end

  def test_curl_command(proxy, environment: :staging)
    builder = case environment
              when :staging, :sandbox
                CurlCommandBuilder::Staging
              when :production
                CurlCommandBuilder::Production
              end.new(proxy)
    builder.command
  end

  def config_based_test_curl_command(proxy, environment: :staging)
    proxy_configs = proxy.proxy_configs.by_environment(environment.to_s).current_versions.to_a
    return if proxy_configs.empty?
    proxy_from_config = CurlCommandBuilder::ProxyFromConfig.new(proxy_configs.first.send(:parsed_content))
    test_curl_command(proxy_from_config, environment: :staging)
  end

  def is_https?(url)
    begin
      uri = URI.parse(url)
      uri.is_a? URI::HTTPS
    rescue URI::InvalidURIError
      false
    end
  end

  def api_backend_hint(api_backend)
    scheme = is_https?(api_backend) ? 'https' : 'http'
    t("formtastic.hints.proxy.api_backend_#{scheme}")
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
    # the idea would be to keep this rolling update disabled for saas
    Rails.application.config.three_scale.apicast_custom_url
  end

  def apicast_urls_readonly?
    # should always return true on prem (deployment option 'hosted') and only return true when self managed in saas (deployment option 'self_managed')
    !(apicast_custom_urls? || @service.proxy.self_managed?)
  end

  def custom_backend?
    # this should probably be its own config
    Rails.configuration.three_scale.active_docs_proxy_disabled
  end

  def apicast_endpoint_input_hint(service, environment:)
    openshift = Rails.application.config.three_scale.apicast_custom_url && service.proxy.hosted?
    t( "formtastic.hints.proxy.endpoint_apicast_2#{'_openshift' if openshift}_html", environment_name: environment)
  end

  def deployment_option_is_service_mesh?(service)
    service.deployment_option =~ /^service_mesh/
  end

  def edit_deployment_option_title(service)
    title = deployment_option_is_service_mesh?(service) ? 'Service Mesh' : 'APIcast'
    t(:edit_deployment_configuration, scope: :api_integrations_controller, deployment: title )
  end

  def promote_to_staging_button_options(proxy)
    return disabled_promote_button_options if proxy.any_sandbox_configs? && !proxy.pending_affecting_changes?

    label = deployment_option_is_service_mesh?(proxy.service) ? 'Update Configuration' : "Promote v. #{proxy.next_sandbox_config_version} to APIcast Staging"
    promote_button_options(label)
  end

  def promote_to_production_button_options(proxy)
    return disabled_promote_button_options if proxy.environments_have_same_config?

    label = "Promote v. #{proxy.next_production_config_version} to APIcast Production"
    promote_button_options(label)
  end

  PROMOTE_BUTTON_COMMON_OPTIONS = { button_html: { class: 'PromoteButton', data: { disable_with: 'promoting…' } } }.freeze

  def promote_button_options(label = 'Promote')
    options = PROMOTE_BUTTON_COMMON_OPTIONS.deep_merge(button_html: { class: 'PromoteButton important-button' })
    [label, options]
  end

  def disabled_promote_button_options
    options = PROMOTE_BUTTON_COMMON_OPTIONS.deep_merge(button_html: { class: 'PromoteButton disabled-button', disabled: true })
    ['Nothing to promote', options]
  end

  def backend_routing_rule(backend_api_config)
    path = StringUtils::StripSlash.strip_slash(backend_api_config.path.presence)
    content_tag :code do
      "/#{path} => #{backend_api_config.backend_api.private_endpoint}"
    end
  end

  def proxy_rules_preview(owner, path: nil)
    proxy_rules = owner.proxy_rules
    last_rule = proxy_rules.last
    return 'None' unless last_rule
    code = content_tag(:code) { "#{path}#{last_rule.pattern} => #{last_rule.metric.name}" }
    code + link_to_more_proxy_rules(proxy_rules, proxy_rules_path_for(owner))
  end

  protected

  def link_to_more_proxy_rules(proxy_rules, url_to_more)
    rules_size = proxy_rules.size
    return '' if rules_size <= 1
    link_to(" and #{rules_size - 1} more.", url_to_more)
  end
end
