# frozen_string_literal: true

module Finance
  class BillingService
    def self.async_call(provider_account, now = Time.zone.now, buyers_scope = nil)
      BillingWorker.enqueue(provider_account, now, buyers_scope)
    end

    # @param account_id [Integer] see #initialize
    def self.call!(account_id, options = {})
      new(account_id, options).call!
    end

    # @param account_id [Integer] see #initialize
    def self.call(account_id, options = {})
      new(account_id, options).call
    end

    attr_reader :account_id, :provider_account_id, :now, :skip_notifications, :lock_service

    # @param account_id [Integer] either a provider account, or a buyer account with :provider_account_id in options
    def initialize(account_id, options = {})
      @account_id = account_id
      @provider_account_id = options[:provider_account_id] || account_id
      @now = Time.zone.parse(options[:now].to_s) || Time.zone.now
      @skip_notifications = options[:skip_notifications]
      @lock_service = Synchronization::BillingLockService.new(account_id.to_s)
    end

    def call!
      lock_service.lock
      call
    rescue Finance::Payment::StripeRateLimitError => error
      # Rate limit errors should retry immediately via Sidekiq
      # Release the lock so retries can proceed without waiting 1 hour
      lock_service.unlock
      report_error(error)
      raise error
    rescue LockBillingError, SpuriousBillingError => error
      report_error(error)
      nil
    end

    def call
      Finance::BillingStrategy.daily(billing_options)
    end

    def notify_billing_finished(_status, billing_results)
      # TODO: Log status

      billing_strategy = provider_account.billing_strategy
      billing_strategy.notify_billing_finished(now)

      billing_strategy.class.notify_billing_results(billing_results)
    end

    def account
      @account ||= Account.find(account_id)
    end

    def provider_account
      @provider_account ||= account.provider? ? account : account.provider_account
    end

    private

    def billing_options
      raise SpuriousBillingError, "provider and buyer ids are the same: #{account_id}" if provider_account_id == account_id

      options = { only: [provider_account_id], now: now, skip_notifications: skip_notifications }
      options[:buyer_ids] = [account_id]
      options
    end

    def report_error(error)
      message = "Failed to perform billing job: #{error.message}"
      System::ErrorReporting.report_error(error, error_message: message,
                                                 error_class: error.class.name)
    end
  end
end
