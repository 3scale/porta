class Admin::Api::ApplicationPlanLimitsController < Admin::Api::BaseController
  representer UsageLimit

  # Limits List per Application Plan
  # GET /admin/api/application_plans/{application_plan_id}/limits.xml
  def index
    respond_with(usage_limits.paginate(page: current_page, per_page: per_page))
  end

  protected

  def application_plan
    @application_plan ||= accessible_application_plans.find(params[:application_plan_id])
  end

  def usage_limits
    @usage_limits ||= application_plan.usage_limits.includes(plan: [:service], metric: [:owner, :parent])
  end
end
