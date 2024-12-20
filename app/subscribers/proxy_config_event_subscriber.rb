# frozen_string_literal: true

class ProxyConfigEventSubscriber
  def call(event)
    case event
    when ProxyConfigs::AffectingObjectChangedEvent
      proxy = Proxy.find(event.proxy_id)
      proxy.affecting_change_history.touch
    else
      raise "Unknown event type #{event.class}"
    end
  end
end
