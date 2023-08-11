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

    attr_reader :account_id, :provider_account_id, :now, :skip_notifications

    # @param account_id [Integer] either a provider account, or a buyer account with :provider_account_id in options
    def initialize(account_id, options = {})
      @account_id = account_id
      @provider_account_id = options[:provider_account_id] || account_id
      @now = Time.zone.parse(options[:now].to_s) || Time.zone.now
      @skip_notifications = options[:skip_notifications]
    end

    def call!
      with_lock { call }
    rescue LockBillingError, SpuriousBillingError => error
      report_error(error)
      nil
    end

    def call
      Finance::BillingStrategy.daily(validate_options(billing_options))
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
      options = { only: [provider_account_id], now: now, skip_notifications: skip_notifications }
      options[:buyer_ids] = [account_id] if provider_account_id != account_id
      options
    end

    def validate_options(billing_options)
      unless billing_options[:only].presence&.size == 1 && billing_options[:buyer_ids].presence&.size == 1
        raise SpuriousBillingError, "Expected to bill individual buyers separately but got providers: #{billing_options[:only].inspect}, buyers: #{billing_options[:buyer_ids].inspect}"
      end
      billing_options
    end

    def with_lock
      # intentionally skip unlocking, no further billing of account within 1 hour allowed
      raise LockBillingError, "Concurrent billing job already running for account #{account_id}" unless Synchronization::NowaitLockService.call("billing:#{account_id}", timeout: 1.hour.in_milliseconds).result

      yield
    end

    def report_error(error)
      message = "Failed to perform billing job: #{error.message}"
      Rails.logger.error(message)
      System::ErrorReporting.report_error(:error_message => message,
                                          :error_class => error.class.name,
                                          :exception => error)
    end
  end
end
