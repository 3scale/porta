# frozen_string_literal: true

class ProxyConfigAffectingChangeWorker < ApplicationJob
  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    proxy = Proxy.find(event.proxy_id)
    proxy.affecting_change_history.touch
  rescue ActiveRecord::RecordNotFound
  end
end
