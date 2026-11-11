# frozen_string_literal: true

module PermittedAccountSettings
  extend ActiveSupport::Concern
  include PermittedPlanChangePermissions

  included do
    helper_method :hide_service_editable?, :cas_server_url_editable?,
                  :account_plans_visible?, :service_plans_visible?
  end

  private

  def hide_service_editable?
    current_account.master? && !ThreeScale.config.onpremises
  end

  def cas_server_url_editable?
    current_account.settings.authentication_strategy.cas?
  end

  def account_plans_visible?
    !current_account.master_on_premises? && current_account.settings.switches[:account_plans].allowed?
  end

  def service_plans_visible?
    !current_account.master_on_premises? && current_account.settings.switches[:service_plans].allowed?
  end

  def permitted_account_settings_params(additional_keys: [], only: nil)
    keys = permitted_settings_keys + additional_keys
    keys &= only if only
    permitted = params.require(:settings).permit(*keys)
    filter_plan_change_permissions(permitted, :change_account_plan_permission, :change_service_plan_permission)
  end

  def permitted_settings_keys
    keys = %i[useraccountarea_enabled signups_enabled public_search account_approval_required]
    keys << :hide_service if hide_service_editable?
    keys << :cas_server_url if cas_server_url_editable?
    if account_plans_visible?
      keys.push(:account_plans_ui_visible, :change_account_plan_permission)
    end
    if service_plans_visible?
      keys.push(:service_plans_ui_visible, :change_service_plan_permission)
    end
    keys
  end
end
