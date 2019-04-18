# frozen_string_literal: true

class UserEventSubscriber
  def after_commit(event)
    case event
    when Users::UserDeletedEvent
      SegmentDeleteUserWorker.perform_later(event.event_id)
    else
      raise "Unknown event type #{event.class}"
    end
  end
end
