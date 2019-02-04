# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    return unless MaxAllowedDaysLoader.valid_configuration?
    invalid_since_date = MaxAllowedDaysLoader.load_account_inactivity.ago
    free_since_date = MaxAllowedDaysLoader.load_contract_unpaid_time.ago
    Account.tenants.free(free_since_date).not_enterprise.without_suspended.without_deleted.inactive_since(invalid_since_date).find_each(&:suspend!)
  end
end
