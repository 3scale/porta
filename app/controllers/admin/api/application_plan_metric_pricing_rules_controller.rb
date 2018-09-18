class Admin::Api::ApplicationPlanMetricPricingRulesController < Admin::Api::BaseController
  representer PricingRule

  wrap_parameters ::PricingRule, name: :pricing_rule

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/pricing_rules.xml"
  ##~ e.responseClass = "List[pricing_rule]"
  #
  ##~ op            = e.operations.add
  ##~ op.nickname   = "metric_pricing_rules"
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Pricing Rules List per Metric"
  ##~ op.description    = "Returns the list of all pricing rules associated to a metric of an application plan."
  ##~ op.group = "application_plan_pricing_rules"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  #

  def index
    respond_with(pricing_rules)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary   = "Pricing Rule Create"
  ##~ op.description = "Creates a pricing rule for an associated application plan."
  ##~ op.group = "application_plan_pricing_rules"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name

  ##~ op.parameters.add :name => "min", :dataType => "int", :paramType => "query", :description => "From (min) hit"
  ##~ op.parameters.add :name => "max", :dataType => "int", :paramType => "query", :description => "To (max) hit"
  ##~ op.parameters.add :name => "cost_per_unit", :dataType => "decimal", :paramType => "query", :description => "Cost per unit"
  #
  def create
    pricing_rule = application_plan.pricing_rules.create(pricing_rule_params)

    respond_with(pricing_rule)
  end

  protected

  def application_plan
    @application_plan ||= accessible_application_plans.find(params[:application_plan_id])
  end

  def metric
    @metric ||= application_plan.service.metrics.find(params[:metric_id])
  end

  def pricing_rules
    @pricing_rules ||= metric.pricing_rules
  end

  def pricing_rule_params
    params.require(:pricing_rule).permit(:min, :max, :cost_per_unit)
      .merge(metric: metric)
  end
end
