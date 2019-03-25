# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    return unless Features::AccountDeletionConfig.valid?
    config = Features::AccountDeletionConfig.config
    invalid_since_date, free_since_date = config.values_at(:account_inactivity, :contract_unpaid_time).map { |value| value.days.ago }
    Account.tenants.free(free_since_date).without_application_plans_with_system_names(config[:disabled_for_app_plans]).without_suspended.without_deleted.inactive_since(invalid_since_date).find_each(&:suspend!)
  end
end
