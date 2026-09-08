class Sites::SettingsController < Sites::BaseController
  provider_required

  before_action :find_settings

  layout 'provider'
  activate_menu :audience, :finance, :credit_card_policies

  def show
    redirect_to :action => :edit
  end

  def edit; end

  def update
    if @settings.update(settings_params)
      redirect_to edit_admin_site_settings_path, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render action: 'edit'
    end
  end

  private

  def settings_params
    params.require(:settings).permit(:cc_terms_path, :cc_privacy_path, :cc_refunds_path)
  end

  def find_settings
    @settings = current_account.settings
  end
end
