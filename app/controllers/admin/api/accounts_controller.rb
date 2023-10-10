class Admin::Api::AccountsController < Admin::Api::BaseController
  paginate only: :index

  representer ::Account

  # Account List
  # GET /admin/api/accounts.xml
  def index
    accounts = buyer_accounts.includes(:users, :settings, :payment_detail, :country, bought_plans: [:original]) # :issuer is polymorphic

    if state = params[:state].presence
      accounts = accounts.where(:state => state.to_s)
    end

    accounts = accounts.paginate(pagination_params)

    respond_with(accounts)
  end

  # Account Find
  # GET /admin/api/accounts/find.xml
  def find
    buyer_account = find_buyer_account
    authorize! :read, buyer_account
    respond_with(buyer_account)
  end

  # Account Read
  # GET /admin/api/accounts/{id}.xml
  def show
    authorize! :read, buyer_account

    respond_with(buyer_account)
  end

  # Account Update
  # PUT /admin/api/accounts/{id}.xml
  def update
    authorize! :update, buyer_account

    buyer_account.vat_rate = params[:vat_rate].to_f if params[:vat_rate]
    buyer_account.settings.attributes = billing_params
    buyer_account.assign_unflattened_attributes(flat_params)
    Annotations::AnnotateWithParamsService.call(buyer_account, flat_params[:annotations_attributes])
    buyer_account.save

    respond_with(buyer_account)
  end

  # Account Delete
  # DELETE /admin/api/accounts/{id}.xml
  def destroy
    authorize! :destroy, buyer_account
    Account.transaction do
      buyer_account.destroy
    end
    respond_with(buyer_account)
  end

  # Account Change Plan
  # PUT /admin/api/accounts/{id}/change_plan.xml
  def change_plan
    authorize! :update, buyer_account

    bought_contract = buyer_account.bought_account_contract
    new_account_plan = bought_contract.change_plan!(account_plan) || bought_contract.plan

    respond_with(new_account_plan, representer: AccountPlanRepresenter)
  end

  # Account Approve
  # PUT /admin/api/accounts/{id}/approve.xml
  def approve
    authorize! :approve, buyer_account

    buyer_account.approve

    respond_with(buyer_account)
  end

  # Account Reject
  # PUT /admin/api/accounts/{id}/reject.xml
  def reject
    authorize! :reject, buyer_account

    buyer_account.reject

    respond_with(buyer_account)
  end

  # Account Reset to Pending
  # PUT /admin/api/accounts/{id}/make_pending.xml
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
      buyer_accounts.first_by_provider_key!(provider_key, error: ActiveRecord::RecordNotFound)
    when current_account.master? && service_token = params[:buyer_service_token]
      buyer_accounts.find_by_service_token!(service_token)
    when email = params[:email].presence
      buyer_users.find_by!(email: email).account
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
