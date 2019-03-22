# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    return unless Features::AccountDeletionConfig.valid?
    invalid_since_date, free_since_date = Features::AccountDeletionConfig.config.values_at(:account_inactivity, :contract_unpaid_time).map { |value| value.days.ago }
    Account.tenants.free(free_since_date).not_enterprise.without_suspended.without_deleted.inactive_since(invalid_since_date).find_each(&:suspend!)
  end
end
