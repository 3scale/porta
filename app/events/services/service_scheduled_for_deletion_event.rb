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

  def after_commit
    DeletePlainObjectWorker.perform_later(Service.find(service_id))
  end
end
