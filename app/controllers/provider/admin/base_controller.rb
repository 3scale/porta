class Provider::Admin::BaseController < FrontendController
  before_action :ensure_provider_domain
  before_action :set_permissions_policy_header

  private

  def set_permissions_policy_header
    cache_key = "account:#{site_account.id}:permission_policy_admin_portal"

    # Cache for 10 minutes, load all account_settings when cache misses
    header_value = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      settings = site_account.account_settings.to_a
      setting = settings.find { |s| s.type == 'AccountSetting::PermissionsPolicyHeaderAdmin' }

      setting ? setting.value : AccountSetting::PermissionsPolicyHeaderAdmin.default_value
    end

    response.headers['Permissions-Policy'] = header_value if header_value.present?
  end
end
