class Admin::Api::BuyersApplicationPlansController < Admin::Api::BuyersBaseController
  representer ApplicationPlan

  # FIXME: QUESTION: these two should be deprecated or removed directly. Check if they are used, not document it on the active docs.
  #
  # swagger
  ## sapi = source2swagger.namespace("Account Management API")
  ## e = sapi.apis.add
  ## e.path = "/admin/api/accounts/{account_id}/application_plans.xml"
  ## e.responseClass = "List[application_plan]"
  ## @desc = "Returns the application plans bought by a partner."
  ## e.description   = @desc
  #
  ## op = e.operations.add
  ## op.nickname   = "buyer_app_plans"
  ## op.httpMethod = "GET"
  #
  ## @access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query" }
  ## @account_id = { :name => "account_id", :description => "ID of the partner account.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  #
  ## op.parameters.add @access_token
  ## op.parameters.add @account_id
  #
  def index
    respond_with(bought_application_plans)
  end

  # swagger
  ## e = sapi.apis.add
  ## e.path = "/admin/api/accounts/{account_id}/application_plans/{id}/buy.xml"
  ## e.responseClass = "application"
  ## @desc = "Creates an application for a partner on a given application plan (deprecated)."
  ## e.description   = @desc
  #
  ## op = e.operations.add
  ## op.deprecated = true
  ## op.nickname   = "buyer_app_plan_buy"
  ## op.httpMethod = "POST"
  ## op.summary    = @desc
  #
  ## @id = { :name => "id", :description => "ID of the application plan.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  #
  ## op.parameters.add @access_token
  ## op.parameters.add @account_id
  ## op.parameters.add @id
  ## op.parameters.add :name => "name", :description => "Name of the application to be created.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ## op.parameters.add :name => "description", :description => "Description of the application to be created.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  #

  #TODO: deprecate this, beware there are clients using it
  def buy
    application = buyer.buy(application_plan, application_plan_params)
    respond_with(application, serialize: application_plan)
  end

  protected

  def bought_application_plans
    @bought_application_plans ||= buyer.bought_application_plans.where(issuer: accessible_services)
  end

  def application_plan
    @application_plan ||= accessible_application_plans.stock.find(params[:id])
  end

  def application_plan_params
    attributes = current_account.fields.for(Cinstance)
    params.permit(*attributes)
  end
end
