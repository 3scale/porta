class Sites::ForumsController < Sites::BaseController
  sublayout 'sites/developer_portals'
  activate_menu :audience, :forum, :settings

  before_action :authorize_forum_feature, :find_settings
  before_action :active_settings_menu, unless: :forum_enabled?

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

  def forum_enabled?
    current_account.forum_enabled?
  end

  def active_settings_menu
    activate_menu :audience, :cms, :forum_settings
  end
end
