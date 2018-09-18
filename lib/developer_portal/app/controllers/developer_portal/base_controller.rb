# Base class of controllers for area for logged in buyers.
class DeveloperPortal::BaseController < DeveloperPortal::ApplicationController
  # TODO: remove when DeveloperPortal is splitted from the main app.
  # The routes will take care of that.
  before_action :ensure_buyer_domain
  before_action :finish_signup_for_paid_plan

  layout 'main_layout'

  include DeveloperPortal::ControllerMethods::PaymentPathsMethods

  respond_to :html, :js, :json

  before_action :verify_requested_format!

  protected

  def require_credit_card_on_signup?
    logged_in? &&
      current_account.requires_credit_card_now?
  end

  def finish_signup_for_paid_plan
    return if unacceptable_payment_gateway?(site_account) || !require_credit_card_on_signup?
    redirect_to edit_payment_details_path
  end
end
