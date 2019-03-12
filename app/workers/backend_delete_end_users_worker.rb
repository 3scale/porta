# frozen_string_literal: true

class BackendDeleteEndUsersWorker
  include Sidekiq::Worker

  sidekiq_options queue: :backend_sync

  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    service_id = event.service_id
    ThreeScale::Core::User.delete_all_for_service(service_id)
  rescue ActiveRecord::RecordNotFound, ThreeScale::Core::APIClient::APIError => exception
    System::ErrorReporting.report_error(exception, parameters: {event_id: event_id, service_id: service_id})
  end
end
