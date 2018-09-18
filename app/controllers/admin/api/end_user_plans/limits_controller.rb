class Admin::Api::EndUserPlans::LimitsController < Admin::Api::BaseController
  representer UsageLimit
  wrap_parameters UsageLimit

  before_action :authorize_end_users

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/end_user_plans/{end_user_plan_id}/metrics/{metric_id}/limits.xml"
  ##~ e.responseClass = "List[limit]"
  #
  ##~ op            = e.operations.add
  ##~ op.nickname   = "limits"
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Limit List for End User Plans "
  ##~ op.description    = "Returns the list of all limits associated to a metric of an end user plan."
  ##~ op.group = "end_user_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  #
  def index
    respond_with(limits)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Limit Create for End User Plans"
  ##~ op.description = "Adds a limit to a metric of an end user plan. All end users with the end user plan (end_user_plan_id) will be constrained by this new limit on the metric (metric_id)."
  ##~ op.group = "end_user_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  #
  ##~ op.parameters.add @parameter_limit_period
  ##~ op.parameters.add :name => "value", :description => "value of the limit.", :dataType => "int", :required => true, :paramType => "query", :allowMultiple => false
  #
  def create
    limit = limits.create(limit_params)

    respond_with(limit)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/end_user_plans/{end_user_plan_id}/metrics/{metric_id}/limits/{id}.xml"
  ##~ e.responseClass = "end_user_plan_limit"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Limit Read for End User Plans"
  ##~ op.description = "Returns a limit on a metric of an end user plan."
  ##~ op.group = "end_user_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_limit_id_by_id
  #
  def show
    respond_with(limit)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Limit Update for End User Plans"
  ##~ op.description = "Updates a limit on a metric of an end user plan."
  ##~ op.group = "end_user_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_limit_id_by_id
  ##~ op.parameters.add @parameter_limit_period
  ##~ op.parameters.add :name => "value", :description => "value of the limit.", :dataType => "int", :required => false, :paramType => "query", :allowMultiple => false
  #
  def update
    limit.update_attributes(limit_params)

    respond_with(limit)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Limit Delete for End User Plans"
  ##~ op.description = "Deletes a limit on a metric of an end user plan."
  ##~ op.group = "end_user_plan_limit"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_limit_id_by_id
  #
  def destroy
    limit.destroy

    respond_with(limit)
  end

  protected

  def plan
    @plan ||= current_account.end_user_plans.find(params[:end_user_plan_id])
  end

  def metric
    @metric ||= plan.metrics.find(params[:metric_id])
  end

  def limits
    @limits ||= metric.usage_limits
  end

  def limit
    @limit ||= limits.find(params[:id])
  end

  def limit_params
    params.fetch(:usage_limit).merge(plan: plan)
  end

  def authorize_end_users
    authorize_switch! :end_users
  end
end
