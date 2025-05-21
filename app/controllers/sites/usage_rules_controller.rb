class Sites::UsageRulesController < Sites::BaseController
  provider_required
  before_action :find_settings
  activate_menu :audience, :accounts, :usage_rules

  def edit
  end

  def update
    if @settings.update(params[:settings])
      redirect_back_or_to admin_site_settings_url, success: t('.success')
    else
      render :edit
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

end
