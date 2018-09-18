class Admin::Api::BuyerAccountPlansController < Admin::Api::BuyersBaseController
  #TODO: security tests are needed!!!!

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/plan.xml"
  ##~ e.responseClass = "account_plan"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Account Fetch Account Plan"
  ##~ op.description = "Returns the account plan associated to an account."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  #
  def show
    respond_with(bought_account_plan)
  end

  private

  def bought_account_plan
    @bought_account_plan ||= buyer.bought_account_plan
  end

end
