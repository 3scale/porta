module EndUserRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :username

  link :self do
    admin_api_service_end_user_url(service, username) if service && username
  end

  link :plan do
    plan && admin_api_service_end_user_plan_path(service, plan)
  end

  link :service do
    service && admin_api_service_path(service)
  end

end
