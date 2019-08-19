# frozen_string_literal: true

module ServiceDiscovery::AuthenticationProviderSupport

  SERVICE_DISCOVERY_SYSTEM_NAME = 'service-discovery'

  def self.included(base)
    base.class_eval do
      has_many :provided_access_tokens, through: :users
    end
  end

  def service_discovery_authentication_provider
    @service_discovery_authentication_provider ||= ::AuthenticationProviders::ServiceDiscoveryProvider.build(account: self)
  end
end
