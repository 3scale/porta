# frozen_string_literal: true

class Services::ServiceDeletedEvent < ServiceRelatedEvent
  def self.create(service)
    provider = service.account || Account.new({id: service.tenant_id}, without_protection: true)

    new(
      service_id:   service.id,
      service_name: service.name,
      provider:     provider,
      metadata: {
        provider_id: provider.id
      }
    )
  end
end
