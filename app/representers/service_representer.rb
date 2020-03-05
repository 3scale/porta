# frozen_string_literal: true

module ServiceRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :name
  property :state
  property :system_name
  property :backend_version
  property :deployment_option
  property :support_email
  property :description

  property :intentions_required
  property :buyers_manage_apps
  property :buyers_manage_keys
  property :referrer_filters_required
  property :custom_keys_enabled
  property :buyer_key_regenerate_enabled
  property :mandatory_app_key
  property :buyer_can_select_plan
  property :buyer_plan_change_permission
  property :notification_settings

  property :created_at
  property :updated_at

  link :metrics do
    admin_api_service_metrics_url(id) if id
  end

  link :self do
    admin_api_service_url(id) if id
  end

  link :service_plans do
    admin_api_service_service_plans_url(id) if id
  end

  link :application_plans do
    admin_api_service_application_plans_url(id) if id
  end

  link :features do
    admin_api_service_features_url(id) if id
  end

  def backend_version
    proxy&.authentication_method
  end

  def notification_settings
    attributes['notification_settings']&.stringify_keys
  end
end
