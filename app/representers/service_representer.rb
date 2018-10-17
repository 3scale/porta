module ServiceRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :name
  property :state
  property :system_name
  property :end_user_registration_required
  property :backend_version
  property :deployment_option
  property :support_email
  property :tech_support_email
  property :admin_support_email
  property :description

  property :created_at
  property :updated_at

  link :metrics do
    admin_api_service_metrics_url(id) if id
  end

  link :end_user_plans do
    admin_api_service_end_user_plans_url(id) if id
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
end
