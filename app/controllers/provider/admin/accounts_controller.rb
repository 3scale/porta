# frozen_string_literal: true

class Provider::Admin::AccountsController < Provider::Admin::Account::BaseController
  activate_menu! :buyers, :accounts, only: [:new]
  activate_menu :account, :overview

  before_action :find_countries, :only => [:edit, :update]
  before_action :find_account
  before_action :deny_unless_can_update, :only => [:update, :edit]
  before_action :check_provider_signup_possible, :only => %i[new create]

  def new
    @provider = current_account.buyers.new
    @user = @provider.admins.new
  end

  def create
    signup_result = Signup::ProviderAccountManager.new(current_account).create(signup_params)
    @provider = signup_result.account
    @user = signup_result.user

    if signup_result.persisted?
      signup_result.account_approve! unless signup_result.account_approval_required?
      ProviderUserMailer.activation(@user).deliver_now
      flash[:notice] = 'Tenant account was successfully created.'
      redirect_to admin_buyers_account_path(@provider)
    else
      render :new
    end
  end

  def show
    @presenter = Provider::Admin::AccountsShowPresenter.new(@account, current_user)
  end

  def edit
    check_require_billing_information
  end

  def update
    check_require_billing_information
    respond_to do |format|
      if @account.update_attributes(account_params)
        flash[:notice] = 'The account information was updated.'
        format.html do
          redirect_to_success
        end
        format.js   { render :js => "jQuery.flash.notice('#{flash[:notice]}')" }
      else
        format.html { render :action => 'edit' }
        format.js   { render :template => 'shared/error' }
      end
    end
  end

  private

  def signup_params
    params_required = params.require(:account)
    account_params = params_required.except(:user)
    user_params = params_required.fetch(:user, {}).merge(signup_type: :created_by_provider)
    Signup::SignupParams.new(plans: [], user_attributes: user_params, account_attributes: account_params, validate_fields: false)
  end

  def check_provider_signup_possible
    redirect_to admin_buyers_accounts_path, alert: 'Please, create an Account Plan and a Service Plan first' unless current_account.signup_provider_possible?
  end

  def account_params
    allowed_fields = current_account.editable_defined_fields_for(current_user).map do |field|
      field_name = field.name
      field_name == 'country' ? 'country_id' : field_name
    end
    allowed_fields << 'timezone'

    account_params = params.require(:account).permit(*allowed_fields)
    extra_fields = params[:account][:extra_fields]

    # extra fields need to be flattened and permitted manually
    if extra_fields.present?
      account_params.merge(extra_fields.permit(*allowed_fields))
    else
      account_params
    end
  end

  def protect_suspended_account
    render :suspended, layout: 'provider/suspended'
  end

  def redirect_to_success
    if upgrading_account?
      redirect_to edit_provider_admin_account_braintree_blue_path(next_step: 'upgrade_plan')
    else
      redirect_to provider_admin_account_path
    end
  end

  def check_require_billing_information
    @account.require_billing_information! if @account.bought_cinstance.paid? || upgrading_account?
  end

  def upgrading_account?
    params[:next_step] == 'credit_card'
  end

  def find_account
    @account = current_account
  end

  def find_countries
    @countries = Country.all
  end

  def deny_unless_can_update
    unless can?(:update, current_account)
      render :plain => 'Action disabled', :status => :forbidden
    end
  end

end
