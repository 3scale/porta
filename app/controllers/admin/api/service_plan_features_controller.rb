class Admin::Api::ServicePlanFeaturesController < Admin::Api::FeaturingsBaseController

  before_action :authorize_service_plans!

  # swagger
  #
  ##~ sapi = source2swagger.namespace("Account Management API")
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/service_plans/{service_plan_id}/features.xml"
  ##~ e.responseClass = "List[feature]"
  ##~ e.description   = "Returns a list of features of an service plan."
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Plan Feature List"
  ##~ op.description = "Returns the list of features of a service plan."
  ##~ op.group = "service_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_plan_id_by_id_name
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Service Plan Feature Add"
  ##~ op.description = "Associates an existing feature to a service plan."
  ##~ op.group = "service_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_plan_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_name
  #
  #
  ##~ e = sapi.apis.ad
  ##~ e.path = "/admin/api/service_plans/{service_plan_id}/features/{id}.xml"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary = "Service Plan Features Delete"
  ##~ op.description = "Removes the association of a feature to a service plan."
  ##~ op.group = "service_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_plan_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_id
  #

  protected

  def plan
    @plan ||= current_account.service_plans
                .where(issuer: accessible_services)
                .find(params[:service_plan_id])
  end

end
