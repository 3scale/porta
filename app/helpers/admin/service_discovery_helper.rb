# frozen_string_literal: true

module Admin::ServiceDiscoveryHelper
  # TODO: Will be retrieved from the .well-known endpoint and used in the presenter
  # Now I just want to test the workflow
  def service_discovery_login_url
    # Construct the redirect URI within a class fetching necessary information from request
    # in another class
    redirect_uri = CGI.escape(auth_service_discovery_callback_url(self_domain: 'provider-admin.example.com.lvh.me', host: 'master-account-admin.example.com.lvh.me:3000'))
    "https://keycloak-default.127.0.0.1.nip.io/auth/realms/master/protocol/openid-connect/auth?client_id=3scale&response_type=code&redirect_uri=#{redirect_uri}"
  end
end
