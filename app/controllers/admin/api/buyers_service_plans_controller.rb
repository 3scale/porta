class Admin::Api::BuyersServicePlansController < Admin::Api::BuyersBaseController
  representer ServicePlan

  ## FIXME: QUESTION: this two probably should go, for the same reason the list of bought applications plans

  # swagger
  ## sapi = source2swagger.namespace("Account Management API")
  ## e = sapi.apis.add
  ## e.path = "/admin/api/accounts/{account_id}/service_plans.xml"
  ## e.responseClass = "List[service_plan]"
  ## @desc = "Returns the service plans bought by a partner."
  ## e.description   = @desc
  #
  ## op = e.operations.add
  ## op.nickname   = "buyer_service_plans"
  ## op.httpMethod = "GET"
  ## op.summary    = @desc
  #
  ## @access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query" }
  ## @account_id = { :name => "account_id", :description => "ID of the partner account.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  #
  ## op.parameters.add @access_token
  ## op.parameters.add @account_id
  #
  def index
    respond_with(bought_service_plans)
  end

  ## e = sapi.apis.add
  ## e.path = "/admin/api/accounts/{account_id}/service_plans/{id}/buy.xml"
  ## e.responseClass = "service_plan"
  ## @desc = "Makes a partner buy a service plan (deprecated)."
  ## e.description   = @desc
  #
  ## op = e.operations.add
  ## op.deprecated = true
  ## op.nickname   = "buyer_service_plan_buy"
  ## op.httpMethod = "POST"
  ## op.summary    = @desc
  #
  ## @id = { :name => "id", :description => "ID of the service plan.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  #
  ## op.parameters.add @access_token
  ## op.parameters.add @account_id
  ## op.parameters.add @id
  #
  def buy
    contract = buyer.buy(service_plan)

    respond_with(contract, serialize: service_plan)
  end

  protected

  def bought_service_plans
    @bought_service_plans ||= buyer.bought_service_plans
  end

  def service_plan
    @service_plan ||= current_account.service_plans.stock.find(params[:id])
  end

end
