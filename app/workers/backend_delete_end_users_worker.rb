# frozen_string_literal: true

class BackendDeleteEndUsersWorker
  include Sidekiq::Worker

  def self.enqueue(event)
    perform_async(event.event_id)
  end

  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    ThreeScale::Core::User.delete_all_for_service(event.service_id)
  end
end
