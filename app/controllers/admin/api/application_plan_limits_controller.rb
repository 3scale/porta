class Admin::Api::ApplicationPlanLimitsController < Admin::Api::BaseController
  representer UsageLimit

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans/{application_plan_id}/limits.xml"
  ##~ e.responseClass = "List[limit]"
  #
  ##~ op             = e.operations.add
  ##~ op.nickname    = "plan_limits"
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Limits List per Application Plan"
  ##~ op.description = "Returns the list of all limits associated to an application plan."
  ##~ op.group = "application_plan_limits"
  #
  ##~ @parameter_per_page_50 = {:name => "per_page", :description => "Number of results per page. Default and max is 50.", :dataType => "int", :paramType => "query", :defaultValue => "50"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page_50
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  #
  def index
    respond_with(usage_limits.paginate(page: current_page, per_page: per_page))
  end

  protected

  def application_plan
    @application_plan ||= accessible_application_plans.find(params[:application_plan_id])
  end

  def usage_limits
    # [Rails bug, will be fixed in Rails 5] https://github.com/rails/rails/issues/8005
    # includes(:plan, metric: [:service])
    @usage_limits ||= application_plan.usage_limits.includes(metric: [:service])
  end
end
