class Sites::BaseController < FrontendController

  before_action :authorize_settings
  after_action :set_permissions_policy_header
  activate_menu :settings

  protected

  def authorize_settings
    authorize! :manage, :settings
  end

  private

  def set_permissions_policy_header
    setting = current_account.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderDeveloper')
    header_value = setting&.value || AccountSetting::PermissionsPolicyHeaderDeveloper.default_value
    
    return if header_value.blank?
    
    response.headers['Permissions-Policy'] = header_value
  end

end
