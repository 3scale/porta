class Buyers::ImpersonationsController < Buyers::BaseController

  # Impersonate impersonation_admin user using provider's sso_key to create an sso_token that works on its admin domain
  def create
    provider= current_account.buyer_accounts.find params[:account_id]

    authorize! :impersonate, provider

    user= provider.users.impersonation_admin!

    sso_token = SSOToken.new user_id: user.id

    sso_token.protocol     = 'http'                unless request.ssl?
    sso_token.redirect_url = params[:redirect_url] if params[:redirect_url] && params[:redirect_url] != "null"
    sso_token.account      = provider

    sso_url = sso_token.sso_url!(target_host(provider))

    respond_to do | format |
      format.json { render json: {url: sso_url}, status: :created }
      format.html { redirect_to sso_url }
    end
  end

end
