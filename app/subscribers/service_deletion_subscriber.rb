# frozen_string_literal: true

class ServiceDeletionSubscriber < AfterCommitSubscriber
  def after_commit(event)
    case event
    when Services::ServiceScheduledForDeletionEvent
      DeleteObjectHierarchyWorker.delete_later(Service.find(event.service_id))
    else
      raise "Unknown event type #{event.class}"
    end
  end
end
