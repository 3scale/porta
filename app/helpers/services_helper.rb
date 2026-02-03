# frozen_string_literal: true

module ServicesHelper
  def human_backend(backend_version)
    {
      "1" => "API key",
      "2" => "App Id",
      "oauth" => "OAuth",
      "oidc" => "OpenID Connect"
    }[backend_version]
  end

  def plugin_language_name(service)
    service.deployment_option.remove('plugin_')
  end

  def deployment_options
    options = Service.deployment_options(current_account)
    {}.merge(options['Gateway'])
        .merge(service_mesh_active? ? options['Service Mesh'] : {})
        .merge(plugins_active? ? options['Plugin'] : {})
  end

  private

  def service_mesh_active?
    current_account.provider_can_use?(:service_mesh_integration)
  end

  def plugins_active?
    false
  end
end
