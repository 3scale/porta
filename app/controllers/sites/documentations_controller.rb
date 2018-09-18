class Sites::DocumentationsController < Sites::BaseController
  # see ForumsController
  skip_before_action :activate_menu_site_or_settings
  activate_menu :serviceadmin

  before_action :authorize_connect
  before_action :find_settings

  def edit
  end

  def update
    attrs = params[:settings].slice( :app_gallery_enabled,
                                     :documentation_enabled,
                                     :documentation_public)

    if @settings.update_attributes(attrs)
      flash[:notice] = 'Documentations settings updated.'
      redirect_to edit_admin_site_documentation_url
    else
      flash[:error] = 'There were problems saving the settings.'
      render :action => 'edit'
    end
  end

  private

  def authorize_connect
    authorize! :manage, :connect_portal
  end

  def find_settings
    @settings = current_account.settings
  end

end
