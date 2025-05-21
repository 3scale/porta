class Sites::ForumsController < Sites::BaseController
  activate_menu :audience, :forum, :settings

  before_action :authorize_forum_feature, :find_settings
  before_action :active_settings_menu

  def edit
  end

  def update
    if @settings.update(params[:settings])
      redirect_to edit_admin_site_forum_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
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

  def active_settings_menu
    activate_menu :audience, :cms, :forum_settings
  end
end
