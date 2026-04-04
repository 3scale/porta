class Provider::Admin::BaseController < FrontendController
  before_action :ensure_provider_domain
  before_action :set_permissions_policy_header

  private

  def set_permissions_policy_header
    header_value = AccountSettings::CachedRetrievalService.call(
      account: site_account,
      setting_name: 'permissions_policy_header_admin'
    ).result

    response.headers['Permissions-Policy'] = header_value if header_value.present?
  end
end
