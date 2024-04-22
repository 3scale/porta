# frozen_string_literal: true

class BackendDeleteServiceTokenWorker
  include Sidekiq::Job

  def self.enqueue(event)
    perform_async(event.event_id)
  end

  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    token = ServiceToken.new(event.data)

    ServiceTokenService.delete_backend(token)
  end
end
