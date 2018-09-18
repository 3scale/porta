class Admin::Api::EndUserPlansController < Admin::Api::BaseController
  representer EndUserPlan
  before_action :authorize_end_users

  # swagger (this is the unnested "fast track" route to get all end user plans)
  #
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/end_user_plans.xml"
  ##~ e.responseClass = "List[end_user_plan]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "End User Plan List (all services)"
  ##~ op.description = "Returns the list of all end user plans across services. Note that end user plans are scoped by service."
  ##~ op.group = "end_user_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  #

  def index
    respond_with(end_user_plans)
  end

  private

  def end_user_plans
    current_account.end_user_plans.where(service_id: accessible_services)
  end

  def authorize_end_users
    authorize_switch! :end_users
  end
end
