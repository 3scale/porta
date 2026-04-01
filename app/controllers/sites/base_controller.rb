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
    cache_key = "account:#{site_account.id}:permission_policy_developer_portal"
    
    # Cache for 10 minutes, load all account_settings when cache misses
    header_value = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      settings = site_account.account_settings.to_a
      setting = settings.find { |s| s.type == 'AccountSetting::PermissionsPolicyHeaderDeveloper' }
      
      setting ? setting.value : AccountSetting::PermissionsPolicyHeaderDeveloper.default_value
    end
    
    response.headers['Permissions-Policy'] = header_value unless header_value.nil?
  end

end
