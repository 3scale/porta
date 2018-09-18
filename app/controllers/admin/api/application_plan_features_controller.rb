class Admin::Api::ApplicationPlanFeaturesController < Admin::Api::FeaturingsBaseController

  # swagger
  #
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans/{application_plan_id}/features.xml"
  ##~ e.responseClass = "List[feature]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Plan Feature List"
  ##~ op.description = "Returns the list of features of the application plan."
  ##~ op.group = "application_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Application Plan Feature Create"
  ##~ op.description = "Associates a feature to an application plan."
  ##~ op.group = "application_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_name
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans/{application_plan_id}/features/{id}.xml"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Application Plan Feature Delete"
  ##~ op.descripttion = "Removes the association of a feature to an application plan."
  ##~ op.group = "application_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_plan_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_id
  #

  protected

  def plan
    @plan ||= accessible_application_plans.find(params[:application_plan_id])
  end
end
