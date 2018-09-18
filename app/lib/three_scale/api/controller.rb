module ThreeScale::Api::Controller

  protected

  # TODO: merge with ApiAuthentication::ByProviderKey
  def authenticate_by_login_or_key(options = {})
    if api_request?
      self.current_account = site_account_by_provider_key
    else
      login_required
    end
  end

  def api_request?
    request.path =~ /\A\/api/ &&  Account.is_admin_domain?(request.host)
    # &&  [ :xml, :json ].include?(request.format.to_sym)
  end

end
