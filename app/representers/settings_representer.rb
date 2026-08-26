# frozen_string_literal: true

module SettingsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource 'settings'

  property :useraccountarea_enabled
  property :hide_service
  property :signups_enabled
  property :account_approval_required
  property :public_search
  property :account_plans_ui_visible
  property :change_account_plan_permission
  property :service_plans_ui_visible
  property :change_service_plan_permission
  property :enforce_sso
end
