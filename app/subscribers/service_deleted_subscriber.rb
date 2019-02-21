# frozen_string_literal: true

class ServiceDeletedSubscriber < AfterCommitSubscriber
  def after_commit(event)
    case event
    when Services::ServiceDeletedEvent
      BackendDeleteEndUsersWorker.perform_async(event.service_id)
    else
      raise "Unknown event type #{event.class}"
    end
  end
end
