# frozen_string_literal: true

class Buyers::AccountsController < Buyers::BaseController
  include SearchSupport
  include ThreeScale::Search::Helpers

  STATE_ACTIONS = %i[approve reject suspend resume].freeze
  STATE_ACTIONS.each { |action| define_method(action) { change_state } }

  before_action :set_plans, :only => %i[new create]
  before_action :find_account, except: %i[index new create]

  activate_menu :buyers, :accounts, :listing

  def index
    @countries = Country.all
    @account_plans = current_account.account_plans.stock
    @search = ThreeScale::Search.new(params[:search] || params)
    @accounts = current_account.buyer_accounts.scope_search(@search).
        # this preloading collides with joins for sorting by country and plan
        includes(:bought_account_plan, :country)
                    .order_by(params[:sort], params[:direction])
                    .paginate(pagination_params)
  end

  def new
    @buyer = current_account.buyers.build
    @user  = @buyer.users.build_with_fields :role => :admin
  end

  def update
    vat = account_params[:vat_rate]
    account.vat_rate = vat if vat # vat_rate is protected attribute

    if account.update_attributes(account_params)
      redirect_to admin_buyers_account_path(account)
    else
      render :edit
    end
  end

  def create
    signup_result = Signup::DeveloperAccountManager.new(current_account).create(signup_params)
    @buyer = signup_result.account

    if signup_result.persisted?
      unless signup_result.user_active?
        signup_result.account_approve!
        signup_result.user_activate!
      end
      flash[:notice] = 'Developer account was successfully created.'
      redirect_to admin_buyers_account_path(@buyer)
    else
      @user = signup_result.user
      render action: :new
    end
  end

  def destroy
    if account.smart_destroy
      flash[:notice] = "The account was successfully #{account.destroyed? ? 'deleted' : 'scheduled for deletion'}."
    else
      flash[:error] = account.errors.full_messages.join(' ')
    end

    redirect_to redirection_path
  end

  def toggle_monthly_charging
    account.settings.toggle!(:monthly_charging_enabled)
    redirect_to(:back)
  end

  def toggle_monthly_billing
    account.settings.toggle!(:monthly_billing_enabled)
    redirect_to(:back)
  end

  def show
    @available_account_plans = current_account.account_plans.stock
  end

  protected

  attr_reader :account

  def find_account
    with_deleted = %w[show resume].include?(action_name)
    @account = current_account.buyer_accounts.without_deleted(!with_deleted).find(params[:id])
  end

  def redirection_path
    account.destroyed? ? admin_buyers_accounts_path : admin_buyers_account_path(account)
  end

  def change_state
    status = account.fire_events(action_name) ? :notice : :error

    account_type = account.provider? ? 'tenant' : 'developer'
    action_name_past = t(action_name, scope: 'buyers.accounts.state_event_past')
    flash[status] = t(status, scope: 'buyers.accounts.change_state', account_type: account_type, state_event: action_name, state_event_past: action_name_past)

    redirect_to admin_buyers_account_path(account)
  end

  def signup_params
    Signup::SignupParams.new(plans: [], user_attributes: user_params.merge(signup_type: :created_by_provider), account_attributes: account_params, validate_fields: false)
  end

  # TODO: using `permit` later
  def account_params
    @account_params ||= params.require(:account).except(:user)
  end

  def user_params
    params.require(:account).fetch(:user, {})
  end

  def set_plans
    unless current_account.create_buyer_possible?
      redirect_to admin_buyers_account_plans_path, alert: 'Please, create an Account Plan first'
    end

    @plans = [] # this is here only to make new_signups/form happy
  end

end
