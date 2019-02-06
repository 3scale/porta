# frozen_string_literal: true

class StaleAccountWorker
  include Sidekiq::Worker

  def perform
    return unless MaxAllowedDaysLoader.valid?
    suspension_date = MaxAllowedDaysLoader.config.account_suspension.days.ago
    free_since_date = MaxAllowedDaysLoader.config.contract_unpaid_time.days.ago
    Account.tenants.free(free_since_date).not_enterprise.suspended_since(suspension_date).find_each(&:schedule_for_deletion!)
  end
end
