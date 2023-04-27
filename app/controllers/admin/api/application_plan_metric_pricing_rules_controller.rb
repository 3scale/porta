class Admin::Api::ApplicationPlanMetricPricingRulesController < Admin::Api::BaseController
  representer PricingRule

  wrap_parameters ::PricingRule, name: :pricing_rule

  # Pricing Rules List per Metric
  # GET /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/pricing_rules.xml
  def index
    respond_with(pricing_rules)
  end

  # Pricing Rule Create
  # POST /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/pricing_rules.xml
  def create
    pricing_rule = application_plan.pricing_rules.create(pricing_rule_params)

    respond_with(pricing_rule)
  end

  # Pricing Rule Delete
  # DELETE /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/pricing_rules/{id}.json
  def destroy
    pricing_rule = pricing_rules.find(params[:id])
    pricing_rule.destroy
    respond_with(pricing_rule)
  end

  protected

  def application_plan
    @application_plan ||= accessible_application_plans.find(params[:application_plan_id])
  end

  def metric
    @metric ||= application_plan.all_metrics.find(params[:metric_id])
  end

  def pricing_rules
    @pricing_rules ||= metric.pricing_rules
  end

  def pricing_rule_params
    params.require(:pricing_rule).permit(:min, :max, :cost_per_unit)
      .merge(metric: metric)
  end
end
