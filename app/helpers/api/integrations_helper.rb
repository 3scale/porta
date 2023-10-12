# frozen_string_literal: true

module Api::IntegrationsHelper
  def api_test_curl(proxy, production = false)
    command = Apicast::CurlCommandBuilder.new(proxy, environment: production ? :production : :staging)
    credentials = proxy.authentication_params_for_proxy(original_names: true)
    tag_id = production ? 'api-production-curl' : 'api-test-curl'
    content_tag :code, id: tag_id, 'data-credentials' => credentials.to_json do
      command.to_s
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

  def api_backend_hint(api_backend)
    scheme = is_https?(api_backend) ? 'https' : 'http'
    t("formtastic.hints.proxy.api_backend_#{scheme}")
  end

  def apicast_configuration_driven?
    # this should be driven by a boolean attribute on the service
    @service.proxy.apicast_configuration_driven
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
    service.deployment_option ||= 'hosted'
    openshift = Rails.application.config.three_scale.apicast_custom_url && service.proxy.hosted?
    t( "formtastic.hints.proxy.endpoint_apicast_2#{'_openshift' if openshift}_html", environment_name: environment)
  end

  def deployment_option_is_service_mesh?(service)
    service.deployment_option =~ /^service_mesh/
  end

  def promote_to_staging_button_options(proxy)
    return disabled_promote_button_options if proxy.any_sandbox_configs? && !proxy.pending_affecting_changes?

    label = deployment_option_is_service_mesh?(proxy.service) ? 'Update Configuration' : "Promote v. #{proxy.next_sandbox_config_version} to Staging APIcast"
    promote_button_options(label)
  end

  def promote_to_production_button_options(proxy)
    return disabled_promote_button_options if proxy.environments_have_same_config?

    label = "Promote v. #{proxy.next_production_config_version} to Production APIcast"
    promote_button_options(label)
  end

  PROMOTE_BUTTON_COMMON_OPTIONS = { button_html: { class: 'PromoteButton', data: { disable_with: 'promoting…' } } }.freeze

  def promote_button_options(label = 'Promote')
    options = PROMOTE_BUTTON_COMMON_OPTIONS.deep_merge(button_html: { class: 'PromoteButton pf-c-button pf-m-primary' })
    [label, options]
  end

  def disabled_promote_button_options
    options = PROMOTE_BUTTON_COMMON_OPTIONS.deep_merge(button_html: { class: 'PromoteButton pf-c-button pf-m-primary', disabled: true })
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
    code = content_tag(:code) { "#{proxy_rule_uri(path, last_rule)} => #{last_rule.metric.name}" }
    code + link_to_more_proxy_rules(proxy_rules, proxy_rules_path_for(owner))
  end

  def proxy_rule_uri(path, rule)
    File.join(path.to_s, rule.pattern.to_s)
  end

  protected

  def link_to_more_proxy_rules(proxy_rules, url_to_more)
    rules_size = proxy_rules.size
    return '' if rules_size <= 1
    link_to(" and #{rules_size - 1} more.", url_to_more)
  end
end
