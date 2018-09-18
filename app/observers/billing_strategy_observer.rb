class BillingStrategyObserver < ActiveRecord::Observer
  observe Finance::BillingStrategy

  def after_update(billing_strategy)
    account_id = billing_strategy.account_id
    Rails.cache.delete("account:#{account_id}:billing_strategy:currency")
  end
end
