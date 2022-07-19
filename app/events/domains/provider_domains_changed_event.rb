class Domains::ProviderDomainsChangedEvent < BaseEventStoreEvent
  def self.create(provider, parent_event = nil)
    new(
      parent_event_id: parent_event&.event_id,
      parent_event_type: parent_event&.class&.name,

      provider:    provider,
      admin_domains: [provider.internal_admin_domain],
      developer_domains: [provider.internal_domain],

      metadata: {
        provider_id: provider.id,
        zync: {
          tenant_id: provider.tenant_id || provider.id,
        }
      }
    )
  end

  def domains
    admin_domains + developer_domains
  end

  def parent_event?
    parent_event_id && parent_event_type
  end

  def after_commit
    ProcessDomainEventsWorker.enqueue(self)
  end

  def self.valid?(account)
    account.provider?
  end
end
