class Sites::UsageRulesController < Sites::BaseController
  provider_required
  before_action :find_settings
  activate_menu :audience, :accounts, :usage_rules

  def edit
  end

  def update
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

  def settings_params
    allowed_attrs = %i[
      useraccountarea_enabled signups_enabled public_search
      account_plans_ui_visible change_account_plan_permission
      service_plans_ui_visible change_service_plan_permission
      account_approval_required hide_service cas_server_url
    ]
    params.require(:settings).permit(*allowed_attrs)
  end
end
