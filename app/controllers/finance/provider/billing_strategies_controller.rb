class Finance::Provider::BillingStrategiesController < Finance::Provider::BaseController

  before_action :find_strategy

  def update
    type = if params['type'] == 'prepaid'
             Finance::PrepaidBillingStrategy
           elsif params['type'] == 'postpaid'
             Finance::PostpaidBillingStrategy
           end

    if type
      @billing_strategy.change_mode(type)
      redirect_back(fallback_location: admin_finance_billing_strategy_path)
    else
      render_error(:not_found)
    end
  end

  private

  def find_strategy
    @billing_strategy = current_account.billing_strategy
  end


end
