# frozen_string_literal: true

class ApplicationDeletedSubscriber < AfterCommitSubscriber
  def after_commit(event)
    case event
    when Applications::ApplicationDeletedEvent then BackendDeleteApplicationWorker.enqueue(event)
    else raise "Unknown event type #{event.class}"
    end
  end
end
