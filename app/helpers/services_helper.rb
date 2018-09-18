module ServicesHelper

  def service_selector( element = :li, services = current_account.accessible_services)
    content_tag element, :id => 'service_selector_widget' do
      form_tag url_for(params), :id => 'service_selector_form', :method => :get do
        concat 'Service: '
        help_bubble('service_selector_help') { "This select selects service! Apparently." }

        options = options_from_collection_for_select(services, :id, :name, @service.try!(:id))
        concat content_tag(:select, options, :id => 'service_selector', :name => 'service_id')

        concat content_tag(:button, 'Change', :type => :submit)
      end
    end
  end

  def human_backend(backend_version)
    case backend_version
    when "1" then "API key"
    when "2" then "App Id"
    when "oauth" then "OAuth"
    when "oidc" then "OpenID Connect"
    end
  end

  def show_mappings?
    !@service.deployment_option.to_s.start_with?('plugin_') && @service.proxiable?
  end

  def path_to_service(service)
    service.proxy.apicast_configuration_driven ? admin_service_integration_path(service) : edit_admin_service_integration_path(service)
  end

  def plugin_language_name
    @service.deployment_option.remove('plugin_')
  end
end
