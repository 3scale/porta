class Services::ServiceScheduledForDeletionEvent < ServiceRelatedEvent
  def self.create(service)
    provider = service.provider
    new(
      service_id:   service.id,
      service_name: service.name,
      provider:     provider,
      metadata: {
        provider_id: provider.id
      }
    )
  end
end
