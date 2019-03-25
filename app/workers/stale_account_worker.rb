# frozen_string_literal: true

class StaleAccountWorker
  include Sidekiq::Worker

  def perform
    return unless Features::AccountDeletionConfig.valid?
    config = Features::AccountDeletionConfig.config
    suspension_date, free_since_date = config.values_at(:account_suspension, :contract_unpaid_time).map { |value| value.days.ago }
    Account.tenants.free(free_since_date).without_application_plans_with_system_names(config[:disabled_for_app_plans]).suspended_since(suspension_date).find_each(&:schedule_for_deletion!)
  end
end
