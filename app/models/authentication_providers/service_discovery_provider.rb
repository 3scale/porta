# frozen_string_literal: true

class AuthenticationProviders::ServiceDiscoveryProvider < AuthenticationProvider
  attr_accessible :account, :token_url, :authorize_url, :user_info_url, :client_id, :client_secret, :system_name,
                  :kind, :skip_ssl_certificate_verification

  def self.build(options = {})
    new do |provider|
      provider.assign_attributes options.merge(defaults)
      provider.readonly!
      provider.freeze
    end
  end

  def self.defaults
    {
      kind: 'service_discovery',
      system_name: ServiceDiscovery::AuthenticationProviderSupport::SERVICE_DISCOVERY_SYSTEM_NAME,
      client_id: ServiceDiscovery::Config.client_id,
      client_secret: ServiceDiscovery::Config.client_secret,
      token_url: ServiceDiscovery::OAuthConfiguration.instance.token_endpoint,
      authorize_url: ServiceDiscovery::OAuthConfiguration.instance.authorization_endpoint,
      user_info_url: ServiceDiscovery::OAuthConfiguration.instance.userinfo_endpoint,
      skip_ssl_certificate_verification: !ServiceDiscovery::Config.verify_ssl?
    }
  end
end
