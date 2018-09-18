class Admin::Api::ApplicationPlanMetricLimitsController < Admin::Api::BaseController
  wrap_parameters UsageLimit
  representer UsageLimit

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/limits.xml"
  ##~ e.responseClass = "List[limit]"
  #
  ##~ op            = e.operations.add
  ##~ op.nickname   = "limits"
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Limit List per Metric"
  ##~ op.description    = "Returns the list of all limits associated to a metric of an application plan."
  ##~ op.group = "application_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  #
  def index
    respond_with(usage_limits)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Limit Create"
  ##~ op.description = "Adds a limit to a metric of an application plan. All applications with the application plan (application_plan_id) will be constrained by this new limit on the metric (metric_id)."
  ##~ op.group = "application_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  #
  ##~ op.parameters.add @parameter_limit_period
  ##~ op.parameters.add :name => "value", :description => "Value of the limit.", :dataType => "int", :required => true, :paramType => "query", :allowMultiple => false
  #
  def create
    usage_limit = usage_limits.new(usage_limit_params)
    usage_limit.plan = application_plan

    usage_limit.save

    respond_with(usage_limit)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans/{application_plan_id}/metrics/{metric_id}/limits/{id}.xml"
  ##~ e.responseClass = "application_plan_limit"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Limit Read"
  ##~ op.description = "Returns a limit on a metric of an application plan."
  ##~ op.group = "application_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_limit_id_by_id
  #
  def show
    respond_with(usage_limit)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Limit Update"
  ##~ op.description = "Updates a limit on a metric of an application plan."
  ##~ op.group = "application_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_limit_id_by_id
  ##~ op.parameters.add @parameter_limit_period
  ##~ op.parameters.add :name => "value", :description => "Value of the limit.", :dataType => "int", :required => false, :paramType => "query", :allowMultiple => false
  #
  def update
    usage_limit.update_attributes(usage_limit_params)

    respond_with(usage_limit)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Limit Delete"
  ##~ op.description = "Deletes a limit on a metric of an application plan."
  ##~ op.group = "application_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_limit_id_by_id
  #
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
    @metric ||= application_plan.service.metrics.find(params[:metric_id])
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
