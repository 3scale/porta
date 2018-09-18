# frozen_string_literal: true

class Admin::Api::AccountPlansController < Admin::Api::BaseController
  representer AccountPlan
  wrap_parameters AccountPlan, include: AccountPlan.attribute_names | %w[state_event]

  before_action :authorize_account_plans!

  ##~ @parameter_account_plan_state_event = {:name => "state_event", :description => "State event of the account plan. It can be 'publish' or 'hide'", :dataType => "string", :required => false, :paramType => "query"}

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account_plans.xml"
  ##~ e.responseClass = "List[account_plan]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Account Plan List"
  ##~ op.description = "Returns the list of all available account plans."
  ##~ op.group = "account_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    respond_with(account_plans)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary   = "Account Plan Create"
  ##~ op.description = "Creates an account plan."
  ##~ op.group = "account_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "name", :description => "Name of the account plan.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_system_name_by_name
  ##~ op.parameters.add @parameter_account_plan_state_event
  #
  def create
    account_plan = account_plans.create(account_plan_create_params)
    respond_with(account_plan)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account_plans/{id}.xml"
  ##~ e.responseClass = "account_plan"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Account Plan Read"
  ##~ op.description = "Returns the account plan by ID."
  ##~ op.group = "account_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_plan_id_by_id
  #
  def show
    respond_with(account_plan)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Account Plan Update"
  ##~ op.description = "Updates an account plan."
  ##~ op.group = "account_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_plan_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the account plan.", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_account_plan_state_event
  #
  def update
    account_plan.update_attributes(account_plan_update_params)
    respond_with(account_plan)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Account Plan Delete"
  ##~ op.description = "Deletes an account plan."
  ##~ op.group = "account_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_plan_id_by_id
  #
  def destroy
    account_plan.destroy

    respond_with(account_plan)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path   = "/admin/api/account_plans/{id}/default.xml"
  ##~ e.responseClass = "account_plan"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Account Plan set to Default"
  ##~ op.description = "Set the account plan to be the default one. The default account plan is used unless another account plan is passed explicitly, for instance on the signup express."
  ##~ op.group = "account_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_plan_id_by_id
  #
  def default
    current_account.update_attribute(:default_account_plan, account_plan)

    respond_with(account_plan)
  end

  private

  DEFAULT_PARAMS = %i[name state_event].freeze

  def account_plan_update_params
    params.require(:account_plan).permit(DEFAULT_PARAMS)
  end

  def account_plan_create_params
    params.require(:account_plan).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def account_plan
    @account_plan ||= account_plans.find(params[:id])
  end

  def account_plans
    @account_plans ||= current_account.account_plans
  end

end
