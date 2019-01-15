# frozen_string_literal: true

class BillingWorker
  include Sidekiq::Worker
  include ThreeScale::SidekiqLockWorker

  sidekiq_options queue: :billing,
                  retry: 3,
                  lock: {
                    timeout: 2.seconds.in_milliseconds,
                    name: proc { |*args| BillingWorker.lock_name(*args) }
                  }

  class LockError < StandardError
    def initialize(metadata = {})
      super 'Billing job failed to acquire required lock at provider level'
      System::ErrorReporting.report_error(self, metadata)
    end
  end

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
      batch_status.try(:delete)
    end
  end

  SPARSING_RATE = (2.0/3).freeze # in seconds/transaction

  def self.sparsing_rate
    SPARSING_RATE
  end

  # @param [Account] provider
  # @param [Time] billing_date
  # @param [ActiveRecord::Relation] buyers_scope
  def self.enqueue(provider, billing_date, buyers_scope = nil)
    payment_gateway = PaymentGateway.find(provider.payment_gateway_type)
    needs_lock = payment_gateway&.need_lock?
    needs_sparsing = payment_gateway&.need_sparsing?

    with_billing_batch(provider.id, billing_date) do
      count = 0
      provider.buyer_accounts.select(:id, :provider_account_id).merge(buyers_scope).find_in_batches do |group|
        group.each do |buyer|
          options = { needs_lock: needs_lock }

          if needs_sparsing
            options[:delay] = (sparsing_rate * count).seconds
            count += 1
          end

          enqueue_for_buyer(buyer, billing_date, **options)
        end
      end
    end
  end

  def self.with_billing_batch(provider_id, billing_date, &block)
    batch = Sidekiq::Batch.new
    batch.description = "Billing (id: #{provider_id})"
    batch.on(:complete, BillingWorker::Callback, batch_id: batch.bid, account_id: provider_id, billing_date: billing_date)
    batch.jobs(&block)
  end

  def self.enqueue_for_buyer(buyer, billing_date, needs_lock: false, delay: 0.second)
    time = billing_date.to_s(:iso8601)
    perform_in(delay, buyer.id, buyer.provider_account_id, time, needs_lock)
  end

  def self.lock_name(_buyer_id, provider_id, *)
    "billing::provider:#{provider_id}"
  end

  # @param [Integer] buyer_id
  # @param [Integer] provider_id
  # @param [String] time
  # @param [Boolean] needs_lock
  def perform(buyer_id, provider_id, time, needs_lock = false)
    if needs_lock && !lock(nil, provider_id).acquire!
      LockError.new buyer_id: buyer_id, provider_id: provider_id, time: time
      return self.class.perform_async buyer_id, provider_id, time, needs_lock
    end

    begin
      billing_results = Finance::BillingService.call!(buyer_id, provider_account_id: provider_id, now: time, skip_notifications: true)
      store_summary(buyer_id, billing_results[provider_id]) if billing_results
    ensure
      lock.release! if needs_lock
    end
  end

  private

  def store_summary(buyer_id, billing_result)
    summary = BillingSummary.new(bid)
    summary.store(buyer_id, billing_result)
  end

  delegate :logger, to: :Rails
end
