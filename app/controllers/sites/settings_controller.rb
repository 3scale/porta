class Sites::SettingsController < Sites::BaseController
  provider_required

  before_action :find_settings
  before_action :find_service, :only => [:edit, :policies, :accessrules]

  layout 'provider'
  activate_menu :audience, :finance, :credit_card_policies

  def show
    redirect_to :action => :edit
  end

  def edit
  end

  def accessrules
  end

  def update
    if @settings.update(params[:settings])
      redirect_to edit_admin_site_settings_path, success: t('.success')
    else
      render :accessrules
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end
end
