# frozen_string_literal: true

class ApplicationDeletedSubscriber < AfterCommitSubscriber
  def after_commit(event)
    case event
    when Applications::ApplicationDeletedEvent then BackendDeleteApplicationWorker.perform_later(event.event_id)
    else raise "Unknown event type #{event.class}"
    end
  end
end
