# frozen_string_literal: true

class StaleAccountWorker
  include Sidekiq::Worker

  def perform
    return unless MaxAllowedDaysLoader.valid_configuration?
    suspension_date = MaxAllowedDaysLoader.load_account_suspension.ago
    free_since_date = MaxAllowedDaysLoader.load_contract_unpaid_time.ago
    Account.tenants.free(free_since_date).not_enterprise.suspended_since(suspension_date).find_each(&:schedule_for_deletion!)
  end
end
