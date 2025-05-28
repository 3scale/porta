# frozen_string_literal: true

class Finance::Provider::SettingsController < Finance::Provider::BaseController
  before_action :set_strategy
  before_action :disable_client_cache

  layout 'provider'

  def show
    activate_menu :audience, :finance, :charging_and_gateway
    @billing_strategy.reload
    @account = current_account
    @current_gateway = ::PaymentGateway.find(@account.payment_gateway_type)
    @payment_gateways = ::PaymentGateway.active_for(@account)
  end

  def update
    if finance_billing_strategy_params['currency'].blank?
      finance_billing_strategy_params['currency'] = nil
    end

    success_msg = if @billing_strategy.numbering_period == finance_billing_strategy_params['numbering_period']
                    t('.success')
                  else
                    t('.success_extra')
                  end

    if @billing_strategy.update(finance_billing_strategy_params)
      redirect_to({ action: :show }, success: success_msg)
    else
      flash.now[:danger] = t('.invalid')
      render :action => :show
    end
  end

  private

  def set_strategy
    @billing_strategy = current_user.account.billing_strategy
  end

  def finance_billing_strategy_params
    @finance_billing_strategy_params ||= params.require(:finance_billing_strategy).permit(:charging_enabled, :currency, :numbering_period, account_attributes: %i[invoice_footnote vat_zero_text id])
  end
end
