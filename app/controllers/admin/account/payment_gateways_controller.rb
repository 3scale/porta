class Admin::Account::PaymentGatewaysController < Finance::Provider::BaseController
  before_action :find_account
  before_action :find_payment_gateways

  def show
  end

  def update
    type = params[:account][:payment_gateway_type]
    options = params[:account][:payment_gateway_options]

    if type.present? && options.present?
      @account.change_payment_gateway!(type, options)
      flash[:notice] = 'Payment gateway details were successfully saved.'
    else
      flash[:error] = 'Failed to save payment gateway details. Choose a payment gateway or disable charging.'
    end
    redirect_to(admin_finance_settings_path)
  end

  private

  def find_account
    @account = current_account
  end

  def find_payment_gateways
    @payment_gateways = ::PaymentGateway.active_for(@account)
  end
end
