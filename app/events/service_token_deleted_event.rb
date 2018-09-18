# frozen_string_literal: true

class ServiceTokenDeletedEvent < ServiceTokenRelatedEvent
  def self.create(service_token)
    new(
      id: service_token.id,
      service_id: service_token.service_id,
      value: service_token.value,
      metadata: {
        provider_id: service_token.account_id || service_token.tenant_id
      }
    )
  end
end
