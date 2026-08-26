# frozen_string_literal: true

class ZyncResyncEvent < BaseEventStoreEvent
  def self.create(model, provider_id:, service_id: nil)
    zync = service_id ? { service_id: } : {}

    new(
      model:,
      metadata: {
        provider_id:,
        zync:
      }
    )
  end
end
