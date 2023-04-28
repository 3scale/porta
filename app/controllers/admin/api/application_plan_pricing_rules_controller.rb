class Admin::Api::ApplicationPlanPricingRulesController < Admin::Api::BaseController
  representer PricingRule

  # Pricing Rules List per Application Plan
  # GET /admin/api/application_plans/{application_plan_id}/pricing_rules.xml
  def index
    respond_with(pricing_rules)
  end

  protected

  def application_plan
    @application_plan ||= accessible_application_plans.find(params[:application_plan_id])
  end

  def pricing_rules
    @pricing_rules ||= application_plan.pricing_rules
  end

end
