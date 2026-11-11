# frozen_string_literal: true

module PermittedServiceSettings
  extend ActiveSupport::Concern
  include PermittedPlanChangePermissions

  included do
    helper_method :buyers_manage_keys_editable?, :buyer_key_regenerate_editable?
  end

  private

  def buyers_manage_keys_editable?(backend_version)
    backend_version.v2?
  end

  def buyer_key_regenerate_editable?(backend_version)
    backend_version.oauth?
  end

  def permitted_service_params(service, **additional_filters)
    permitted = params.require(:service).permit(*permitted_service_keys(service), **additional_filters)
    filter_plan_change_permissions(permitted, :buyer_plan_change_permission)
  end

  def permitted_service_keys(service)
    submitted = params.require(:service).permit(:backend_version)
    backend_version = if submitted.key?(:backend_version)
                        Service.new(account: service.account, backend_version: submitted[:backend_version]).backend_version
                      else
                        service.backend_version
                      end
    keys = %i[
      name system_name description support_email deployment_option backend_version
      intentions_required buyers_manage_apps referrer_filters_required
      buyer_can_select_plan buyer_plan_change_permission custom_keys_enabled state_event
      txt_support terms
    ]
    keys.push(:buyers_manage_keys, :mandatory_app_key) if buyers_manage_keys_editable?(backend_version)
    keys << :buyer_key_regenerate_enabled if buyer_key_regenerate_editable?(backend_version)
    keys << { notification_settings: [web_provider: [], email_provider: [], web_buyer: [], email_buyer: []] }
    keys
  end
end
