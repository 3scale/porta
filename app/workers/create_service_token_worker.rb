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
  end
end
