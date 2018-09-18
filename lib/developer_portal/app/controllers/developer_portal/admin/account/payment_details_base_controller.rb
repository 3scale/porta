class DeveloperPortal::Admin::Account::PaymentDetailsBaseController < DeveloperPortal::BaseController

  layout 'main_layout'
  skip_before_action :protect_access

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
    current_account.updating_payment_detail = true
    if current_account.update_attributes account_params
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
    if flash[:success] && plan_changes?
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
end
