class Sites::BaseController < FrontendController

  before_action :authorize_settings
  activate_menu :settings

  protected

  def authorize_settings
    authorize! :manage, :settings
  end

  def permissions_policy_header_account
    site_account
  end

  def permissions_policy_header_setting_name
    'permissions_policy_header_developer'
  end

end
