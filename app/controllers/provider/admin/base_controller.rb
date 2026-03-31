class Provider::Admin::BaseController < FrontendController
  before_action :ensure_provider_domain
  before_action :set_permissions_policy_header

  private

  def set_permissions_policy_header
    # Use site_account instead of current_account to work before user login
    account = site_account
    cache_key = "account:#{account.id}:permission_policy_admin_portal"
    
    # Cache for 10 minutes, load all account_settings when cache misses
    header_value = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      # Load all account_settings to prepare for future Settings → AccountSettings migration
      settings = account.account_settings.to_a
      setting = settings.find { |s| s.type == 'AccountSetting::PermissionsPolicyHeaderAdmin' }
      
      # If setting exists, use its value (even if blank)
      # If no setting exists, use default value
      setting ? setting.value : AccountSetting::PermissionsPolicyHeaderAdmin.default_value
    end
    
    return if header_value.blank?
    
    response.headers['Permissions-Policy'] = header_value
  end
end
