class Domains::ProviderDomainsChangedEvent < BaseEventStoreEvent
  def self.create(provider)
    new(
      provider:    provider,
      admin_domains: [ provider.self_domain ],
      developer_domains: [ provider.domain ],
      metadata: {
        provider_id: provider.id,
        zync: {
          tenant_id: provider.tenant_id || provider.id,
        }
      }
    )
  end

  def self.valid?(account)
    account.provider?
  end
end
