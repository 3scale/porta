module UsageLimitRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource :limit

  property :id
  property :period
  property :value
  property :metric_id

  property :created_at
  property :updated_at

  include MetricLinksRepresenter

  link :self do
    polymorphic_url([:admin, :api, plan, metric, :limits], id: id) if plan && metric && id
  end

  link :plan do
    case plan_type
    when 'AccountPlan'
      admin_api_account_plan_url(plan_id)
    else 'ServicePlan' # TODO: make this route flat (without service)
      polymorphic_url([:admin, :api, plan.service, plan])
    end if plan_id
  end
end
