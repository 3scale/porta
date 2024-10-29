# frozen_string_literal: true

class Provider::Admin::CMS::VisitPortalController < Provider::Admin::CMS::BaseController
  # Encrypt the CMS token under a temporary SSO token and redirect to the Developer Portal
  def with_token
    cms_token = current_account.settings.cms_token!
    expires_at = Time.now.utc + 1.minute
    encrypted_token = ThreeScale::SSO::Encryptor.new(current_account.settings.sso_key, expires_at.to_i).encrypt_token cms_token

    redirect_to access_code_url(
      host: current_account.external_domain,
      cms_token: encrypted_token,
      access_code: current_account.site_access_code,
      return_to: return_to)
  end

  def return_to
    params.permit(:return_to)[:return_to]
  end
end
