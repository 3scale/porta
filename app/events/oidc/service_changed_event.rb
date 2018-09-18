# frozen_string_literal: true

class OIDC::ServiceChangedEvent < BaseEventStoreEvent

  # Create OIDC::ServiceCreated Event

  def self.create(service)
    new(
      id: service.id,
      service: service,
      metadata: {
        provider_id: service.account_id
      }
    )
  end
end
