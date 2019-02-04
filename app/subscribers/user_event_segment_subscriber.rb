# frozen_string_literal: true

class UserEventSegmentSubscriber
  def after_commit(event)
    case event
    when Users::UserDeletedEvent
      # TODO: This should call a worker and the worker to the service. That way it would be in Background
      SegmentDeleteService.delete_user(event)
    else
      raise "Unknown event type #{event.class}"
    end
  end
end
