# frozen_string_literal: true

class BillingWorker
  include Sidekiq::Worker

  sidekiq_options queue: :billing, retry: 3

  class Callback
    delegate :logger, to: 'Rails'

    def on_complete(status, options)
      batch_id = options['batch_id']
      account_id = options['account_id']
      billing_date = options['billing_date']

      logger.info("Billing batch complete: #{batch_id} (account_id: #{account_id}, billing_date: #{billing_date})")

      billing_summary = BillingSummary.new(batch_id)
      billing_service = Finance::BillingService.new(account_id, now: billing_date)
      billing_service.notify_billing_finished(status, billing_summary.build_result(account_id, billing_date))
      billing_summary.unstore

      batch_status = Sidekiq::Batch::Status.new(batch_id)
      batch_status.delete
    end
  end

  # @param [Account] provider
  # @param [Time] billing_date
  # @param [ActiveRecord::Relation] buyers_scope
  def self.enqueue(provider, billing_date, buyers_scope = nil)
    with_billing_batch(provider.id, billing_date) do
      provider.buyer_accounts.select(:id, :provider_account_id).merge(buyers_scope).find_in_batches do |group|
        group.each { |buyer| enqueue_for_buyer(buyer, billing_date) }
      end
    end
  end

  def self.enqueue_for_buyer(buyer, billing_date)
    time = billing_date.to_s(:iso8601)
    perform_async(buyer.id, buyer.provider_account_id, time)
  end

  def self.with_billing_batch(provider_id, billing_date, &block)
    batch = Sidekiq::Batch.new
    batch.description = "Billing (id: #{provider_id})"
    batch.on(:complete, BillingWorker::Callback, batch_id: batch.bid, account_id: provider_id, billing_date: billing_date)
    batch.jobs(&block)
  end

  # @param [Integer] buyer_id
  # @param [Integer] provider_id
  # @param [String] time
  def perform(buyer_id, provider_id, time)
    billing_results = Finance::BillingService.call!(buyer_id, provider_account_id: provider_id, now: time, skip_notifications: true)
    store_summary(buyer_id, billing_results[provider_id]) if billing_results
  end

  private

  def store_summary(buyer_id, billing_result)
    summary = BillingSummary.new(bid)
    summary.store(buyer_id, billing_result)
  end

  delegate :logger, to: :Rails
end
