class Buyers::ImpersonationsController < Buyers::BaseController

  # Impersonate impersonation_admin user using provider's sso_key to create an sso_token that works on its admin domain
  def create
    provider= current_account.buyer_accounts.find params[:account_id]

    authorize! :impersonate, provider

    user = provider.users.impersonation_admin!
    expires_at = Time.now.utc.round + 1.minute
    signature = Impersonate::Signature.generate(user.id, expires_at)

    impersonate_url = provider_impersonate_url(signature:, expires_at: expires_at.to_i, host: provider.external_admin_domain, port: request.port)

    respond_to do | format |
      format.json { render json: {url: impersonate_url}, status: :created }
      format.html { redirect_to impersonate_url }
    end
  end

end
