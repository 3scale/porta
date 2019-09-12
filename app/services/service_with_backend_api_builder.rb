# frozen_string_literal: true

class ServiceWithBackendApiBuilder
  def initialize(provider)
    @provider = provider
  end

  def call(service_params:, backend_api_params: nil)
    service = provider.services.build
    service.attributes = service_params.permit(PERMITTED_PARAMS)
    # raw_params.permit(:service).permit(*permitted_params)
    service
  end

  private

  attr_reader :provider

  PERMITTED_PARAMS = [
    :name, :description, :support_email, :deployment_option, :backend_version,
    :intentions_required, :buyers_manage_apps, :referrer_filters_required,
    :buyer_can_select_plan, :buyer_plan_change_permission, :buyers_manage_keys,
    :buyer_key_regenerate_enabled, :mandatory_app_key, :custom_keys_enabled, :state_event,
    :txt_support, :terms, :system_name,
    {notification_settings: [web_provider: [], email_provider: [], web_buyer: [], email_buyer: []]}
  ].freeze
  private_constant :PERMITTED_PARAMS
end
