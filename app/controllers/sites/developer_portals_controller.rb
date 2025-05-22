class Sites::DeveloperPortalsController < Sites::BaseController
  activate_menu :audience, :cms

  def edit
    @settings = settings
  end

  def update
    if settings.update(settings_params)
      redirect_to edit_admin_site_developer_portal_path, success: t('.success')
    else
      flash.now[:danger] = t('.error')
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
