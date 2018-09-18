# frozen_string_literal: true

class ServiceTokenEventSubscriber < AfterCommitSubscriber
  def after_commit(event)
    case event
    when ServiceTokenDeletedEvent then BackendDeleteServiceTokenWorker.enqueue(event)
    else raise "Unknown event type #{event.class}"
    end
  end
end
