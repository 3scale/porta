# frozen_string_literal: true

class StaleAccountWorker
  include Sidekiq::Worker

  def perform
    return unless AccountDeletionConfig.valid?
    suspension_date, free_since_date = AccountDeletionConfig.config.values_at(:account_suspension, :contract_unpaid_time).map { |value| value.days.ago }
    Account.tenants.free(free_since_date).not_enterprise.suspended_since(suspension_date).find_each(&:schedule_for_deletion!)
  end
end
