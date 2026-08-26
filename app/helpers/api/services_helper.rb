module Api::ServicesHelper

  def link_to_service service
    link_to service.name, admin_service_path(service)
  end

  def delete_service_link(service, options = {})
    msg = t('api.services.forms.definition_settings.delete_confirmation', name: j(service.name))
    delete_link_for(admin_service_path(service), {data: { confirm: msg }, class: 'pf-c-button pf-m-danger', method: :delete}.merge(options) )
  end
end
