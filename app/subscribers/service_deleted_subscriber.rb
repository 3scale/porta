# frozen_string_literal: true

class ServiceDeletedSubscriber < AfterCommitSubscriber
  def after_commit(event)
    case event
    when Services::ServiceDeletedEvent then BackendDeleteEndUsersWorker.enqueue(event)
    else raise "Unknown event type #{event.class}"
    end
  end
end
