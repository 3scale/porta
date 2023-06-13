# frozen_string_literal: true

module BillingResultsTestHelpers
  class << self
    def clear_billing_locks
      lock_keys = System.redis.keys("lock:billing:*")
      System.redis.del(*lock_keys) if lock_keys.present?
    end
  end

  protected

  delegate :clear_billing_locks, to: :BillingResultsTestHelpers

  def mock_billing_results(period, provider)
    billing_results = Finance::BillingStrategy::Results.new(period)
    billing_results.start(provider.billing_strategy)
    billing_results
  end

  def mock_billing_success(period, provider)
    billing_results = mock_billing_results(period, provider)
    billing_results.success(provider.billing_strategy)
    billing_results
  end

  def mock_billing_failure(period, provider, failed_buyers = [])
    billing_results = mock_billing_results(period, provider)
    provider.billing_strategy.instance_variable_set(:@failed_buyers, failed_buyers)
    billing_results.failure(provider.billing_strategy)
    billing_results
  end
end
