# frozen_string_literal: true

class ProxyConfigAffectingChangeWorker < ApplicationJob
  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    proxy = Proxy.find(event.proxy_id)
    proxy.affecting_change_history.touch
  rescue ActiveRecord::StatementInvalid => exception
    # logging to help us understand the problem
    proxy_config_affecting_change = proxy.reload.send(:proxy_config_affecting_change)
    parameters = {
      proxy_created_at: proxy.created_at,
      proxy_updated_at: proxy.updated_at,
      proxy_affecting_change_created_at: proxy_config_affecting_change&.created_at,
      proxy_affecting_change_updated_at: proxy_config_affecting_change&.updated_at
    }
    System::ErrorReporting.report_error(exception, parameters: parameters)
    raise
  rescue ActiveRecord::RecordNotFound
  end
end
