# frozen_string_literal: true

class Admin::Api::SettingsController < Admin::Api::BaseController

  clear_respond_to
  respond_to :json

  wrap_parameters ::Settings, include: ::Settings.attribute_names + %w[account_approval_required]

  representer ::Settings

  before_action :validate_enforcing_sso_allowed, only: [:update]

  # TODO: Add support for Permissions-Policy headers via AccountSettings:
  #   - permissions_policy_admin_portal
  #   - permissions_policy_dev_portal
  # These should be virtual attributes in Settings model that delegate to AccountSettings
  ALLOWED_PARAMS = %i[
    useraccountarea_enabled hide_service signups_enabled public_search
    account_plans_ui_visible change_account_plan_permission service_plans_ui_visible change_service_plan_permission
    enforce_sso
  ].freeze

  # Settings Read
  # GET /admin/api/settings.json
  def show
    respond_with(settings)
  end

  # Settings Update
  # PUT /admin/api/settings.json
  def update
    AccountSetting.transaction do
      (settings.update(settings_params) & update_approval_required) || raise(ActiveRecord::Rollback)
    end
    respond_with(settings)
  end

  private

  def settings
    @settings ||= current_account.settings
  end

  def settings_params
    @settings_params ||= params.require(:settings).permit(*ALLOWED_PARAMS)
  end

  def update_approval_required
    approval = params.require(:settings).permit(:account_approval_required)
    return true unless approval.key?(:account_approval_required) && settings.approval_required_editable?

    plan = settings.default_account_plan
    return true if plan.update(approval_required: approval[:account_approval_required])

    plan.errors[:approval_required].each { settings.errors.add(:account_approval_required, _1) }
    false
  end

  def validate_enforcing_sso_allowed
    return unless settings_params.key?(:enforce_sso)

    settings.enforce_sso = settings_params[:enforce_sso]
    return unless settings.enforce_sso?

    sso_validator = EnforceSSOValidator.new(account: current_account)

    return if sso_validator.valid?

    render json: { errors: { enforce_sso: [sso_validator.error_message] } }, status: :unprocessable_entity
  end
end
