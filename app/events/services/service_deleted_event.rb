# frozen_string_literal: true

class Services::ServiceDeletedEvent < ServiceRelatedEvent
  def self.create(service)
    new(
      service_id: service.id,
      service_name: service.name,
      metadata: {
        provider_id: service.account_id || service.tenant_id
      }
    )
  end
end
