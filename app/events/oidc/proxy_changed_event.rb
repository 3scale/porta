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

    # TODO: second assertion is probably useless, or not. Revisit this in the future once we've seen this is safe. See https://github.com/3scale/porta/pull/2929/files#r846345372
    service.backend_version.oauth? || service.backend_version_change_to_be_saved&.include?('oauth') || service.saved_change_to_backend_version&.include?('oauth')
  end
end
