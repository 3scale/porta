# frozen_string_literal: true

class ResyncEvent < BaseEventStoreEvent
  def self.create(provider_id:, service_id: nil)
    zync = service_id ? { service_id: } : {}

    new(
      metadata: {
        provider_id:,
        zync:
      }
    )
  end
end
