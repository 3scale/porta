require 'uri'

class Domains::ProxyDomainsChangedEvent < BaseEventStoreEvent
  def self.create(proxy, parent_event = nil)
    new(
      parent_event_id: parent_event&.event_id,
      parent_event_type: parent_event&.class&.name,

      proxy: MissingModel::MissingProxy.new(id: proxy.id),
      staging_domains: [ proxy.staging_domain ],
      production_domains: [ proxy.production_domain ],

      metadata: {
        provider_id: (provider_id = proxy.provider&.id),
        zync: {
          tenant_id: proxy.tenant_id || proxy.provider&.tenant_id || provider_id,
          service_id: proxy.service_id,
        }
      }
    )
  end

  def domains
    staging_domains + production_domains
  end

  def parent_event?
    parent_event_id && parent_event_type
  end

  def after_commit
    ProcessDomainEventsWorker.enqueue(self)
  end

  def self.valid?(proxy)
    # TODO: check if deployment_option or domains actually changed
    proxy && proxy.provider&.persisted? # Proxy's service or account may have been deleted
  end
end
