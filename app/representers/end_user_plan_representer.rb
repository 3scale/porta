module EndUserPlanRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name

  property :default

  property :created_at
  property :updated_at

  link :service do
    admin_api_service_url(service_id) if service_id
  end

  link :self do
    admin_api_service_end_user_plan_url(service_id, id) if service_id && id
  end

  def default
    default?
  end
end
