# frozen_string_literal: true

module Account::ServiceDiscoverySupport
  extend ActiveSupport::Concern

  SERVICE_DISCOVERY_SYSTEM_NAME = 'service-discovery'

  def service_discovery_authentication_provider
    @service_discovery_authentication_provider ||= ::AuthenticationProvider::ServiceDiscoveryProvider.build(account: self)
  end
end
