# frozen_string_literal: true

class CreateServiceTokenWorker
  include Sidekiq::Worker

  # @param [Services::ServiceCreatedEvent] event
  def self.enqueue(event)
    perform_async(event.event_id)
  end

  # @param [String] event_id
  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    token = event.service.service_tokens.first_or_create!(value: event.token_value)

    ServiceTokenService.update_backend(token)
  rescue ActiveRecord::RecordNotFound, ActiveJob::DeserializationError => exception
    exception_message = exception.message
    if exception_message =~ /Couldn't find Service with 'id'/
      Rails.logger.info "CreateServiceTokenWorker#perform raised #{exception.class} with message: #{exception_message}"
    else
      System::ErrorReporting.report_error(exception, parameters: {event_id: event_id})
    end
  end
end
