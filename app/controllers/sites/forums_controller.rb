class Sites::ForumsController < Sites::BaseController
  sublayout 'sites/developer_portals'
  activate_submenu :portal

  before_action :authorize_forum_feature, :find_settings

  def edit
  end

  def update
    if @settings.update_attributes(params[:settings])
      flash[:notice] = 'Forum settings updated.'
      redirect_to edit_admin_site_forum_url
    else
      flash[:error] = 'There were problems saving the settings.'
      render :action => 'edit'
    end
  end

  private

  def authorize_forum_feature
    authorize! :manage, :forum
  end

  def find_settings
    @settings = current_account.settings
  end
end
