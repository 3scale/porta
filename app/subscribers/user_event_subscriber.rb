# frozen_string_literal: true

class UserEventSubscriber
  def call(event)
    case event
    when Users::UserDeletedEvent
      return unless Features::SegmentDeletionConfig.enabled?
      SegmentDeleteUserWorker.perform_later(event.event_id)
    else
      raise "Unknown event type #{event.class}"
    end
  end
end
