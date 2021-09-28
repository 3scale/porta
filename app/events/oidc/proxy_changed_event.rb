# frozen_string_literal: true

class OIDC::ProxyChangedEvent < BaseEventStoreEvent

  # Create OIDC::ProxyChanged Event

  def self.create(proxy)
    new(
      proxy: proxy,
      metadata: {
        provider_id: proxy.provider.id,
        zync: {
          oidc_endpoint: proxy.oidc_issuer_endpoint,
          service_id: proxy.service_id,
        }
      }
    )
  end

  # :reek:NilCheck but backend_version_change just can be nil
  def self.valid?(proxy)
    service = proxy.try(:service)
    return unless service
    service.backend_version.oauth? || service.saved_changes&.include?('oauth')
  end
end
