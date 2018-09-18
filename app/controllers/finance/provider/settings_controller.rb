class Finance::Provider::SettingsController < Finance::Provider::BaseController

  before_action :set_strategy
  layout 'provider'


  def show
    activate_menu :settings, :billing
    @billing_strategy.reload
    @account = current_account
    @current_gateway = ::PaymentGateway.find(@account.payment_gateway_type)
    @payment_gateways = ::PaymentGateway.active_for(@account)
  end

  def update
    if params['finance_billing_strategy']['currency'].blank?
      params['finance_billing_strategy']['currency'] = nil
    end

    if @billing_strategy.numbering_period != params['finance_billing_strategy']['numbering_period']
      ok_message = "Already existent invoices won't change their id."
    end

    if @billing_strategy.update_attributes(params['finance_billing_strategy'])
      flash[:message] = 'Finance settings updated.' << ok_message.to_s
      redirect_to :action => 'show'
    else
      flash[:message] = 'Invalid finance settings'
      render :action => :show
    end
  end

  private

  def set_strategy
    @billing_strategy = current_user.account.billing_strategy
  end

end
