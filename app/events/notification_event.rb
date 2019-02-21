# frozen_string_literal: true

class NotificationEvent < BaseEventStoreEvent

  # Create Notification Event

  def self.create(system_name, event)
    provider_id = event.try(:provider)&.id || event.metadata[:provider_id]

    new(
      parent_event_id: event.event_id,
      system_name:     system_name.to_s,
      provider_id:     provider_id,
      metadata: {
        provider_id: provider_id
      }
    )
  end

  def after_commit
    ProcessNotificationEventWorker.enqueue(self)
  end
end
