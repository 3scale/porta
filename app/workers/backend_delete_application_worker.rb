# frozen_string_literal: true

class BackendDeleteApplicationWorker < ApplicationJob
  queue_as :low

  def perform(event_id)
    @event = EventStore::Repository.find_event!(event_id)

    delete_associations

    ThreeScale::Core::Application.delete(event.service_backend_id, event.application_id)
  rescue ActiveRecord::RecordNotFound => exception
    System::ErrorReporting.report_error(exception, parameters: {event_id: event_id})
  end

  private

  attr_reader :event

  def delete_associations
    delete_params = { application_id: event.application.id, service_backend_id: event.service_backend_id, application_backend_id: event.application_id }
    [ApplicationKeyBackendService, ReferrerFilterBackendService].each { |klass| klass.delete_all(**delete_params) }
  end

end
