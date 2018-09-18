class Admin::Api::ApplicationPlanPricingRulesController < Admin::Api::BaseController
  representer PricingRule

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans/{application_plan_id}/pricing_rules.xml"
  ##~ e.responseClass = "List[pricing_rule]"
  #
  ##~ op            = e.operations.add
  ##~ op.nickname   = "pricing_rules"
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Pricing Rules List per Application Plan"
  ##~ op.description    = "Returns the list of all pricing rules associated to an application plan."
  ##~ op.group = "application_plan_pricing_rules"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  #
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
