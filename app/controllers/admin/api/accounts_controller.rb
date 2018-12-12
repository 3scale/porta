class Admin::Api::AccountsController < Admin::Api::BaseController
  paginate only: :index

  representer ::Account

  # swagger
  ##~ @base_path = ""
  #
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts.xml"
  ##~ e.responseClass = "List[account]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Account List"
  ##~ op.description = "Returns the list of buyer accounts (the accounts that consume your API). Filters by state are available and the results can be paginated."
  ##~ op.group = "account"
  #
  ##~ @parameter_account_state = {:name => "state", :description => "Filter your partners by State. Allowed values are pending, approved, rejected", :dataType => "string", :paramType => "query", :allowableValues => "pending,approved,rejected"}
  ##~ @parameter_page = {:name => "page", :description => "Page in the paginated list. Defaults to 1.", :dataType => "int", :paramType => "query", :defaultValue => "1"}
  ##~ @parameter_per_page = {:name => "per_page", :description => "Number of results per page. Default and max is 500.", :dataType => "int", :paramType => "query", :defaultValue => "500"}
  ##
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_state
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  ##
  #
  def index
    accounts = buyer_accounts.includes(:users, :settings, :payment_detail, :country, bought_plans: [:original]) # :issuer is polymorphic

    if state = params[:state].presence
      accounts = accounts.where(:state => state.to_s)
    end

    accounts = accounts.paginate(pagination_params)

    respond_with(accounts)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/find.xml"
  ##~ e.responseClass = "account"
  #
  ##~ op = e.operations.add
  #
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Account Find"
  ##~ op.description = "Find an account by the username or email of its users (username takes precendence over email)."
  ##~ op.group = "account"
  #
  ##~ @parameter_username = {:name => "username", :description => "Username of the account user.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_email = {:name => "email", :description => "Email of the account user.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_id = {:name => "user_id", :description => "ID of the account user.", :dataType => "integer", :paramType => "query"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_username
  ##~ op.parameters.add @parameter_email
  ##~ op.parameters.add @parameter_id
  #
  def find
    buyer_account = find_buyer_account
    authorize! :read, buyer_account
    respond_with(buyer_account)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{id}.xml"
  ##~ e.responseClass = "account"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Account Read"
  ##~ op.description = "Returns a buyer account."
  ##~ op.group = "account"
  #
  ##~ @parameter_account_id = { :name => "id", :description => "ID of the account.", :dataType => "int", :required => true, :paramType => "path" }
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  def show
    authorize! :read, buyer_account

    respond_with(buyer_account)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Account Update"
  ##~ op.description = "Updates a buyer account by ID. You can modify all the fields on the account, including custom fields defined in the fields definition section of your admin portal."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  #  example fields
  #
  ##~ op.parameters.add :name => "org_name", :description => "Organization name of the account.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "monthly_billing_enabled", :description => "Updates monthly billing status.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "monthly_charging_enabled", :description => "Updates monthly charging status.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_extra
  #
  def update
    authorize! :update, buyer_account

    buyer_account.vat_rate = params[:vat_rate].to_f if params[:vat_rate]
    buyer_account.settings.attributes = billing_params
    buyer_account.update_with_flattened_attributes(flat_params)

    respond_with(buyer_account)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Account Delete "
  ##~ op.description = "Deletes a buyer account. Deleting an account removes all users, applications and service subscriptions to the account."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  def destroy
    authorize! :destroy, buyer_account
    Account.transaction do
      buyer_account.destroy
    end
    respond_with(buyer_account)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{id}/change_plan.xml"
  ##~ e.responseClass = "account"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Account Change Plan"
  ##~ op.description = "Changes the account plan for the buyer account."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  ##~ op.parameters.add :name => "plan_id", :description => "ID of the target account plan", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "query", :threescale_name => "account_plan_ids"
  #
  def change_plan
    authorize! :update, buyer_account

    bought_contract = buyer_account.bought_account_contract
    new_account_plan = bought_contract.change_plan!(account_plan) || bought_contract.plan

    respond_with(new_account_plan, representer: AccountPlanRepresenter)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{id}/approve.xml"
  ##~ e.responseClass = "account"
  ##~ e.description = "Approves a partner account."
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Account Approve"
  ##~ op.description = "Approves the account (changes the state to live). Accounts need to be approved explicitly via this API after creation. The state can also be updated by PUT on /admin/api/accounts/{id}.xml"
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  def approve
    authorize! :approve, buyer_account

    buyer_account.approve

    respond_with(buyer_account)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{id}/reject.xml"
  ##~ e.responseClass = "account"

  #
  ##~ op = e.operations.add

  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Account Reject"
  ##~ op.description = "Rejects the account (changes the state to rejected). An account can be rejected after creation, the workflow for account creation can have a validation process that ends in approving or rejecting the account submission. The state can also be updated by PUT on /admin/api/accounts/{id}.xml"
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  def reject
    authorize! :reject, buyer_account

    buyer_account.reject

    respond_with(buyer_account)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{id}/make_pending.xml"
  ##~ e.responseClass = "account"

  #
  ##~ op = e.operations.add

  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Account Reset to Pending"
  ##~ op.description = "Resets the state of the account to pending so that it can be approved or rejected again."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  def make_pending
    authorize! :update, buyer_account

    buyer_account.make_pending

    respond_with(buyer_account)
  end

  protected

  def authorize!(*args)
    current_user ? super : logged_in?
  end

  def buyer_accounts
    @buyer_accounts ||= current_account.buyers
  end

  def buyer_account
    @buyer_account ||= buyer_accounts.find(params[:id])
  end

  def buyer_users
    @buyer_users ||= current_account.buyer_users
  end

  def account_plan
    @account_plan ||= current_account.account_plans.find(params[:plan_id])
  end

  def billing_params
    @billing_params ||= params.permit(:monthly_billing_enabled, :monthly_charging_enabled)
  end

  private

  def find_buyer_account
    case
    when username = params[:username]
      buyer_users.find_by!(username: username).account
    when user_id = params[:user_id]
      buyer_users.find(user_id).account
    when current_account.master? && provider_key = params[:buyer_provider_key]
      buyer_accounts.find_by_provider_key!(provider_key, error: ActiveRecord::RecordNotFound)
    when current_account.master? && service_token = params[:buyer_service_token]
      buyer_accounts.find_by_service_token!(service_token)
    else
      buyer_users.find_by!(email: params[:email]).account
    end
  end
end
