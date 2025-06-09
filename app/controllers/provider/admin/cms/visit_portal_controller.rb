# frozen_string_literal: true

class Provider::Admin::CMS::VisitPortalController < Provider::Admin::CMS::BaseController
  # Encrypt the CMS token under a temporary SSO token and redirect to the Developer Portal
  def with_token
    expires_at = Time.now.utc.round + 1.minute
    signature = CMS::Signature.generate(current_account.id, expires_at)

    redirect_to access_code_url(
      host: current_account.external_domain,
      signature:,
      expires_at: expires_at.to_i,
      access_code: current_account.site_access_code,
      return_to:,
      cms: cms_mode)
  end

  private

  def return_to
    params.permit(:return_to)[:return_to]
  end

  def cms_mode
    session[:cms]
  end
end
