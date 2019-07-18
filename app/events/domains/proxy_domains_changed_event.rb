require 'uri'

class Domains::ProxyDomainsChangedEvent < BaseEventStoreEvent
  def self.create(proxy)
    new(
      proxy: MissingModel::MissingProxy.new(id: proxy.id),
      staging_domains: extract_domain(proxy.sandbox_endpoint),
      production_domains: extract_domain(proxy.endpoint),

      metadata: {
        provider_id: (provider_id = proxy.provider&.id),
        zync: {
          tenant_id: proxy.tenant_id || proxy.provider&.tenant_id || provider_id,
          service_id: proxy.service_id,
        }
      }
    )
  end

  def self.valid?(proxy)
    !!proxy # TODO: check if deployment_option or domains actually changed
  end

  def self.extract_domain(url)
    [ URI(url.presence || '').host ].compact
  rescue ArgumentError, URI::InvalidURIError
    # nothing
  end
end
