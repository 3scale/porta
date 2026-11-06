class Sites::UsageRulesController < Sites::BaseController
  include PermittedAccountSettings

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
    permitted = params.require(:settings).permit(*permitted_settings_keys)
    filter_plan_change_permissions(permitted, :change_account_plan_permission, :change_service_plan_permission)
  end
end
