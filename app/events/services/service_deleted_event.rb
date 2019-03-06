# frozen_string_literal: true

class Services::ServiceDeletedEvent < ServiceRelatedEvent
  def self.create(service)
    provider = service.account || Account.new({id: service.tenant_id}, without_protection: true)

    data = {
      service_id:   service.id,
      service_name: service.name,
      service_created_at: service.created_at.to_s,
      metadata: {
        provider_id: provider.id
      }
    }
    data[:provider] = provider if provider.persisted?

    new(data)
  end
end
