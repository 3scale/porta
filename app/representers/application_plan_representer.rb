module ApplicationPlanRepresenter
  include ThreeScale::JSONRepresenter
  include PlanRepresenter

  wraps_resource

  property :custom
  property :system_name
  property :end_user_required

  def custom
    customized?
  end

  link :service do
    admin_api_service_url(issuer_id) if issuer_id
  end

  link :self do
    admin_api_service_application_plan_url(issuer_id, id) if id && issuer_id
  end
end
