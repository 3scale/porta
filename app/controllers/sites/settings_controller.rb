class Sites::SettingsController < Sites::BaseController
  provider_required

  before_action :find_settings
  before_action :find_service, :only => [:edit, :policies, :accessrules]

  layout 'provider'
  activate_menu :settings, :policies

  def show
    redirect_to :action => :edit
  end

  def edit
  end

  def accessrules
  end

  def update
    if @settings.update_attributes(params[:settings])
      flash[:notice] = 'Settings updated.'
      redirect_to edit_admin_site_settings_path
    else
      render :accessrules
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end
end
