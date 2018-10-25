module Api::ServicesHelper

  def link_to_service service
    link_to service.name, admin_service_path(service)
  end

  def list_items_or_empty collection, empty_message, &block
    if collection.empty?
      content_tag(:li, empty_message, :class => 'item empty')
    else
      collection.each do |item|
        yield(item)
      end
      nil
    end
  end

  def friendly_service_setting service, setting
    value = service.send setting
    message, value = case setting
                     when :custom_keys_enabled
      ['Custom application keys are VALUE', value ? 'enabled' : 'disabled']
                     when :buyers_manage_keys
      ['Users VALUE manage application keys',  value ? 'can' : "cannot"]
                     when :buyer_can_select_plan
      ['Users VALUE when creating an application',  value ? 'can select a plan' : "cannot select a plan"]
                     when :buyer_plan_change_permission
      value = case value.to_sym
              when :request
                "request plan change"
              when :direct
                "directly change plans"
              when :none
                "not change plans"
              end
      ['Users can VALUE', value]
                     when :buyers_manage_apps
      ['Users VALUE manage applications', value ? 'can' : "can't"]
                     else
      ["Setting #{setting} - VALUE", value]
    end

    return unless message && value

    message.gsub('VALUE', content_tag(:strong, value)).html_safe
  end

  def delete_service_link(service, options = {})
    msg = t('api.services.forms.definition_settings.delete_confirmation', name: h(service.name))
    delete_link_for(admin_service_path(service), {data: { confirm: msg }, method: :delete}.merge(options) )
  end

  def refresh_service_link(service, options = {})
    msg = t('api.services.forms.definition_settings.refresh_confirmation', name: h(service.name))
    action_link_to(:refresh, provider_admin_service_discovery_service_path(service), {data: { confirm: msg }, method: :put}.merge(options) )
  end
end
