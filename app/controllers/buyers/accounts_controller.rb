# frozen_string_literal: true

class Buyers::AccountsController < Buyers::BaseController
  include SearchSupport
  include ThreeScale::Search::Helpers

  STATE_ACTIONS = %i[approve reject suspend resume].freeze
  STATE_ACTIONS.each { |action| define_method(action) { change_state } }

  before_action :set_plans, :only => %i[new create]
  before_action :find_account, except: %i[index new create]

  activate_menu :buyers, :accounts, :listing

  helper_method :presenter

  def index
    @countries = Country.all
    @search = ThreeScale::Search.new(params[:search] || params)

    respond_to do |format|
      format.html
      format.json { render json: presenter.render_json }
    end
  end

  def new
    @buyer = current_account.buyers.build
    @user  = @buyer.users.build_with_fields :role => :admin
  end

  def update
    vat = account_params[:vat_rate]
    account.vat_rate = vat if vat # vat_rate is protected attribute

    if account.update(account_params)
      redirect_to admin_buyers_account_path(account), success: t('.success')
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
      redirect_to admin_buyers_account_path(@buyer), success: t('.success')
    else
      @user = signup_result.user
      flash.now[:danger] = signup_result.errors.messages.without(:user).values.join('. ')
      render action: :new
    end
  end

  def destroy
    if account.smart_destroy
      flash[:success] = account.destroyed? ? t('.destroyed') : t('.scheduled_for_deletion')
    else
      flash[:danger] = account.errors.full_messages.join(' ')
    end

    redirect_to redirection_path
  end

  def toggle_monthly_charging
    account.settings.toggle!(:monthly_charging_enabled)
    redirect_back_or_to(redirection_path)
  end

  def toggle_monthly_billing
    account.settings.toggle!(:monthly_billing_enabled)
    redirect_back_or_to(redirection_path)
  end

  def show
    @available_account_plans = current_account.account_plans.stock
    @account = account.decorate
  end

  protected

  attr_reader :account

  def find_account
    with_deleted = %w[show resume].include?(action_name)
    @account = current_account.buyer_accounts.not_master.without_deleted(!with_deleted).find(params[:id])
  end

  def redirection_path
    account.destroyed? ? admin_buyers_accounts_path : admin_buyers_account_path(account)
  end

  def change_state
    account_type = account.provider? ? 'tenant' : 'developer'

    flash_type = account.fire_events(action_name) ? :success : :danger

    flash[flash_type] = t(".#{flash_type}", account_type:).capitalize

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
      redirect_to admin_buyers_account_plans_path, danger: t('buyers.accounts.set_plans_error')
    end

    @plans = [] # this is here only to make new_signups/form happy
  end

  def presenter
    @presenter ||= Buyers::AccountsIndexPresenter.new(provider: current_account,
                                                      user: current_user,
                                                      params: params)
  end
end
