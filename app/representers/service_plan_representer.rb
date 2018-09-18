module ServicePlanRepresenter
  include ThreeScale::JSONRepresenter
  include PlanRepresenter

  wraps_resource

  property :approval_required

  link :service do
    admin_api_service_url(issuer_id) if issuer_id
  end

  link :self do
    admin_api_service_service_plan_url(issuer_id, id) if issuer_id && id
  end
end
