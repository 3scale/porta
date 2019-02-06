# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    return unless MaxAllowedDaysLoader.valid?
    invalid_since_date = MaxAllowedDaysLoader.config.account_inactivity.days.ago
    free_since_date = MaxAllowedDaysLoader.config.contract_unpaid_time.days.ago
    Account.tenants.free(free_since_date).not_enterprise.without_suspended.without_deleted.inactive_since(invalid_since_date).find_each(&:suspend!)
  end
end
