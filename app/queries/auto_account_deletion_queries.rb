# frozen_string_literal: true

module AutoAccountDeletionQueries
  module_function
  def should_be_suspended
    return Account.none unless Features::AccountDeletionConfig.enabled?
    config = Features::AccountDeletionConfig.config.to_h.slice(:account_inactivity, :contract_unpaid_time, :disabled_for_app_plans)
    Account.tenants.without_suspended.without_deleted
      .free(config[:contract_unpaid_time].days.ago)
      .inactive_since(config[:account_inactivity].days.ago)
      .lacks_cinstance_with_plan_system_name(config[:disabled_for_app_plans])
  end

  def should_be_scheduled_for_deletion
    return Account.none unless Features::AccountDeletionConfig.enabled?
    config = Features::AccountDeletionConfig.config.to_h.slice(:account_suspension, :contract_unpaid_time, :disabled_for_app_plans)
    Account.tenants
      .free(config[:contract_unpaid_time].days.ago)
      .suspended_since(config[:account_suspension].days.ago)
      .lacks_cinstance_with_plan_system_name(config[:disabled_for_app_plans])
  end
end
