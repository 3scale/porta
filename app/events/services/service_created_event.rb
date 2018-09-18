class Services::ServiceCreatedEvent < BaseEventStoreEvent
  class << self
    def create(service, user)
      provider = service.provider

      new(
        service:     service,
        user:        user,
        provider:    provider,
        token_value: generate_token_value,
        metadata: {
          provider_id: provider.try!(:id)
        }
      )
    end

    def generate_token_value
      SecureRandom.hex(32)
    end
  end

  def after_commit
    CreateServiceTokenWorker.enqueue(self)
  end
end
