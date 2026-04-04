class Sites::BaseController < FrontendController

  before_action :authorize_settings
  before_action :set_permissions_policy_header
  activate_menu :settings

  protected

  def authorize_settings
    authorize! :manage, :settings
  end

  private

  def set_permissions_policy_header
    header_value = AccountSettings::CachedRetrievalService.call(
      account: site_account,
      setting_name: 'permissions_policy_header_developer'
    ).result

    response.headers['Permissions-Policy'] = header_value if header_value.present?
  end

end
