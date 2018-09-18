module Provider::Admin::AuthenticationProvidersHelper
  def branding_relevant?
    ::AuthenticationProvider.branded_available?
  end
end
