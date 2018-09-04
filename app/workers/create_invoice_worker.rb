# frozen_string_literal: true

# Creates a zero-value invoice to a given buyer of a given provider
# WARNING: Only for testing purposes -- NOT to be used in production
class CreateInvoiceWorker
  include Sidekiq::Worker

  sidekiq_options queue: :billing, retry: 0

  def self.enqueue(provider_account, buyer_account, period = Month.new(Time.now.utc))
    perform_async(provider_account.id, buyer_account.id, period.to_param)
  end

  # [Integer] provider_account_id
  # [Integer] buyer_account_id
  # [String] period, YYYY-MM
  def perform(provider_account_id, buyer_account_id, period)
    return if Rails.env.production? # I said NOT TO BE USED IN PRODUCTION!!!

    provider_account = Account.providers_with_master.find(provider_account_id)

    provider_account.billing_strategy.create_invoice!(
      buyer_account: provider_account.buyer_accounts.find(buyer_account_id),
      period: Month.parse_month(period)
    )
  end
end
