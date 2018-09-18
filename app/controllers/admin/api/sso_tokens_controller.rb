class Admin::Api::SSOTokensController < Admin::Api::BaseController

  wrap_parameters :sso_token, :include => [:user_id, :username, :expires_in, :redirect_url, :protocol], :format => [ :url_encoded_form ]

  # parameters:
  #   * user_id
  #   * expires_in
  #   * provider_key
  #   * protocol
  def create
    sso_token = SSOToken.new sso_token_params
    sso_token.account = domain_account
    sso_token.save

    respond_with(sso_token, representer: SSOTokenRepresenter, location: nil)
  end

  def provider_create
    provider = site_account.buyers.find(params[:provider_id])
    sso_token = SSOToken.new
    sso_token.account = provider
    sso_token.username = ThreeScale.config.impersonation_admin['username']
    sso_token.expires_in = params.fetch(:expires_in) { sso_token.expires_in }

    sso_token.save

    response.headers['Expires'] = sso_token.expires_at.httpdate unless sso_token.new_record?

    respond_with(sso_token, representer: SSOTokenRepresenter, location: nil)
  end

  private

  def sso_token_params
    params.require(:sso_token)
  end

end
