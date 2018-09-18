class Admin::Api::AccountPlanFeaturesController < Admin::Api::FeaturingsBaseController

  before_action :authorize_account_plans!

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account_plans/{account_plan_id}/features.xml"
  ##~ e.responseClass = "List[feature]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Account Plan Features List"
  ##~ op.description = "Returns the list of the features associated to an account plan."
  ##~ op.group = "account_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_plan_id_by_id_name
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account_plans/{account_plan_id}/features/{id}.xml"
  ##~ e.responseClass = "List[feature]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Account Plan Features Create"
  ##~ op.description = "Associate an account feature to an account plan."
  ##~ op.group = "account_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_plan_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_id
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Account Plan Features Delete"
  ##~ op.description = "Deletes the association of an account feature to an account plan."
  ##~ op.group = "account_plan_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_plan_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_id
  #

  protected

  def plan
    @plan ||= current_account.account_plans.find(params[:account_plan_id])
  end

  def features
    @features ||= plan.features
  end
end
