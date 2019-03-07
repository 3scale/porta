# frozen_string_literal: true

class BackendDeleteServiceWorker
  include Sidekiq::Worker

  def self.enqueue(event)
    perform_async(event.event_id)
  end

  class Callback
    def on_success(_status, options)
      service = Service.new({id: options['service_id']}, without_protection: true)
      service.delete_backend_service
    end
  end

  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    service_id = event.service_id
    batch = Sidekiq::Batch.new
    batch.description = "Deleting in Backend the Service ##{service_id}"
    batch.on(:success, BackendDeleteServiceWorker::Callback, {'service_id' => service_id})
    batch.jobs do
      BackendDeleteEndUsersWorker.perform_async(event_id)
      BackendDeleteStatsWorker.perform_async(event_id)
    end
  rescue ActiveRecord::RecordNotFound => exception
    System::ErrorReporting.report_error(exception, parameters: {event_id: event_id})
  end
end
