# frozen_string_literal: true

class ProxyConfigEventSubscriber
  def call(event)
    case event
    when ProxyConfigs::AffectingObjectChangedEvent then ProxyConfigAffectingChangeWorker.perform_later(event.event_id)
    else raise "Unknown event type #{event.class}"
    end
  end
end
