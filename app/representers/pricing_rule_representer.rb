module PricingRuleRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :cost_per_unit
  property :min
  property :max

  property :created_at
  property :updated_at

  include MetricLinksRepresenter

  link :plan do
    admin_api_service_application_plan_url(plan.service, plan) if plan_id
  end
end
