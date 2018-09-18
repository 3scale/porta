# frozen_string_literal: true

module Finance
  class BillingService
    class LockBillingError < StandardError; end

    def self.async_call(provider_account, now = Time.zone.now, buyers_scope = nil)
      BillingWorker.enqueue(provider_account, now, buyers_scope)
    end

    def self.call!(account_id, options = {})
      new(account_id, options).call!
    end

    def self.call(account_id, options = {})
      new(account_id, options).call
    end

    attr_reader :account_id, :provider_account_id, :now, :skip_notifications

    def initialize(account_id, options = {})
      @account_id = account_id
      @provider_account_id = options[:provider_account_id] || account_id
      @now = Time.zone.parse(options[:now].to_s) || Time.zone.now
      @skip_notifications = options[:skip_notifications]
    end

    def call!
      with_lock { call }
    rescue LockBillingError => error
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
      options = { only: [provider_account_id], now: now, skip_notifications: skip_notifications }
      options[:buyer_ids] = [account_id] if provider_account_id != account_id
      options
    end

    def with_lock
      raise LockBillingError, "Concurrent billing job already running for account #{account_id}" unless BillingLock.create(account_id: account_id).persisted?

      begin
        yield
      ensure
        BillingLock.delete(account_id)
      end
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
