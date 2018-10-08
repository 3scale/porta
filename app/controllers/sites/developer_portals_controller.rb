# frozen_string_literal: true

class Sites::DeveloperPortalsController < Sites::BaseController
  sublayout 'sites/developer_portals'

  def edit
    @settings = settings
  end

  def update
    if settings.update_attributes(settings_params)
      flash[:notice] = 'Developer Portal settings updated.'
      redirect_to edit_admin_site_developer_portal_path
    else
      flash[:error] = 'There were problems saving the settings.'
      render :edit
    end
  end

  private

  def settings_params
    params[:settings]
  end

  def settings
    @settings ||= current_account.settings
  end

end
