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

  ALLOWED_PARAMS = %i[cc_terms_path cc_privacy_path cc_refunds_path].freeze

  def update
    if @settings.update(settings_params)
      redirect_to edit_admin_site_settings_path, success: t('.success')
    else
      render :accessrules
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

  def settings_params
    params.require(:settings).permit(*ALLOWED_PARAMS).reject { |_, v| v.to_s.empty? }
  end
end
