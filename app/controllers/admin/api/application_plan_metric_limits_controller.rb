class Admin::Api::ApplicationPlanMetricLimitsController < Admin::Api::BaseController
  wrap_parameters UsageLimit
  representer UsageLimit

  # Limit List per Metric
  # GET /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/limits.xml
  def index
    respond_with(usage_limits)
  end

  # Limit Create
  # POST /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/limits.xml
  def create
    usage_limit = usage_limits.new(usage_limit_params)
    usage_limit.plan = application_plan

    usage_limit.save

    respond_with(usage_limit)
  end

  # Limit Read
  # GET /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/limits/{id}.xml
  def show
    respond_with(usage_limit)
  end

  # Limit Update
  # PUT /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/limits/{id}.xml
  def update
    usage_limit.update_attributes(usage_limit_params)

    respond_with(usage_limit)
  end

  # Limit Delete
  # DELETE /admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/limits/{id}.xml
  def destroy
    usage_limit.destroy

    respond_with(usage_limit)
  end

  protected

  def application_plan
    @application_plan ||= accessible_application_plans.find(params[:application_plan_id])
  end

  def metric
    # if service_id were passed in the url service.metrics would be ok
    @metric ||= application_plan.all_metrics.find(params[:metric_id])
  end

  def usage_limits
    @usage_limits ||= metric.usage_limits
  end

  def usage_limit
    @usage_limit ||= usage_limits.find(params[:id])
  end

  def usage_limit_params
    params.fetch(:usage_limit)
  end

end
