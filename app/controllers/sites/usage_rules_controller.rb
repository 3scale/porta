class Sites::UsageRulesController < Sites::BaseController
  provider_required
  before_action :find_settings
  activate_menu :audience, :accounts, :usage_rules

  def edit
  end

  def update
    if @settings.update_attributes(params[:settings])
      flash[:notice] = 'Settings updated.'
      redirect_back(fallback_location: admin_site_settings_url)
    else
      render :edit
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

end
