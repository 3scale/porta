# frozen_string_literal: true

class Admin::Api::SettingsController < Admin::Api::BaseController

  clear_respond_to
  respond_to :json

  wrap_parameters ::Settings, include: ::Settings.attribute_names + %w[account_approval_required]

  representer ::Settings

  before_action :enforce_sso_allowed?, only: [:update], if: -> { settings_params[:enforce_sso] }

  ALLOWED_PARAMS = %i[
    useraccountarea_enabled hide_service signups_enabled account_approval_required strong_passwords_enabled
    public_search account_plans_ui_visible change_account_plan_permission service_plans_ui_visible
    change_service_plan_permission enforce_sso
  ].freeze

  # Settings Read
  # GET /admin/api/settings.json
  def show
    respond_with(settings)
  end

  # Settings Update
  # PUT /admin/api/settings.json
  def update
    settings.update(settings_params)
    respond_with(settings)
  end

  private

  def settings
    @settings ||= current_account.settings
  end

  def settings_params
    @settings_params ||= params.require(:settings).permit(*ALLOWED_PARAMS)
  end

  def enforce_sso_allowed?
    sso_validator = EnforceSSOValidator.new(account: current_account)

    return if sso_validator.valid?

    render json: { errors: { enforce_sso: [sso_validator.error_message] } }, status: :unprocessable_entity
  end
end
