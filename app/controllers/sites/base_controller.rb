class Sites::BaseController < FrontendController

  before_action :authorize_settings
  activate_menu :settings

  protected

  def authorize_settings
    authorize! :manage, :settings
  end



end
