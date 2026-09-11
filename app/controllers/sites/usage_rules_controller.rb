class Sites::UsageRulesController < Sites::BaseController
  provider_required
  before_action :find_settings
  activate_menu :audience, :accounts, :usage_rules

  def edit
  end

  def update
    update_approval_required
    if @settings.update(settings_params)
      redirect_back_or_to admin_site_settings_url, success: t('.success')
    else
      render :edit
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

  ALLOWED_PARAMS = %i[
    useraccountarea_enabled signups_enabled public_search
    account_plans_ui_visible change_account_plan_permission
    service_plans_ui_visible change_service_plan_permission
    hide_service cas_server_url
  ].freeze

  def settings_params
    params.require(:settings).permit(*ALLOWED_PARAMS)
  end

  def update_approval_required
    return unless @settings.approval_required_editable?
    value = params.dig(:settings, :account_approval_required)
    return if value.to_s.empty?
    current_account.account_plans.default.update_attribute(:approval_required, value)
  end
end
