# TODO: DRY: refactor PaymentGateways controllers and reduce duplication

class DeveloperPortal::Admin::Account::PaymentDetailsBaseController < DeveloperPortal::BaseController
  layout 'main_layout'
  skip_before_action :protect_access

  after_action  :check_multiple_payment_failures, only: [:hosted_success]
  before_action :ensure_buyer_domain
  before_action :authorize_finance
  before_action :check_correct_url , :except => :update
  skip_before_action :finish_signup_for_paid_plan

  activate_menu! :topmenu => :account, :main_menu => :account

  liquify prefix: 'accounts/payment_gateways'

  include ::DeveloperPortal::ControllerMethods::PaymentPathsMethods
  include ::DeveloperPortal::ControllerMethods::PlanChangesMethods

  def show
  end

  def edit
    assign_drops countries: Liquid::Drops::Country.wrap(Country.all)
    render template: 'accounts/payment_gateways/edit'
  end

  def update
    if update_billing_address
      redirect_to payment_details_path, notice: 'Your billing address was successfully stored'
    else
      flash[:notice] = 'Failed to update your billing address data. Check the required fields'
      assign_drops countries: Liquid::Drops::Country.wrap(Country.all)
      render template: 'accounts/payment_gateways/edit'
    end
  end

  protected

  def authorize_finance
    authorize! :manage, :credit_card
  end

  def check_multiple_payment_failures
    Payment::MultipleFailureChecker.new(current_account, @payment_result, user_session).call
  end

  def check_correct_url
    gateway_type = controller_name.to_sym

    if !site_account.is_billing_buyers?
      render_error 'Payment Gateway not found', status: :not_found
    elsif site_account.payment_gateway_type != gateway_type
      redirect_to(payment_details_path)
    elsif site_account == current_account
      redirect_to(admin_dashboard_url)
    end
  end

  def after_hosted_success_path
    if flash[:notice] && plan_changes?
      admin_account_plan_changes_path
    else
      after_hosted_success_without_plan_changes_path
    end
  end

  def after_hosted_success_without_plan_changes_path
    url_for(action: :show)
  end

  def account_params
    allowed_fields = %i[name address1 address2 city country state phone zip first_name last_name]
    params.require(:account).permit(billing_address: allowed_fields)
  end

  def update_billing_address
    current_account.transaction do
      raise ActiveRecord::Rollback unless current_account.update(account_params) && update_address_on_payment_gateway

      true
    end
  end

  # To be overridden by specific gateway controllers
  def update_address_on_payment_gateway
    true
  end
end
