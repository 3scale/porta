# frozen_string_literal: true

class BackendDeleteStatsWorker
  include Sidekiq::Worker

  def perform(event_id)
    @event = EventStore::Repository.find_event!(event_id)

    ThreeScale::Core::Service.delete_stats(event.service_id, {})
  end
end
