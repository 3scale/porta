# frozen_string_literal: true

class BackendDeleteStatsWorker
  include Sidekiq::Worker

  def perform(event_id)
    @event = EventStore::Repository.find_event!(event_id)

    ThreeScale::Core::Service.delete_stats(event.service_id, delete_job)
  end

  attr_reader :event

  def delete_job
    service = Service.new({id: event.service_id}, without_protection: true)
    deleted_associations = DeletedObjectEntry.where(owner: service)
    {
      applications: deleted_associations.contracts.pluck(:object_id),
      metrics: deleted_associations.metrics.pluck(:object_id),
      users: [],
      from: Time.parse(event.service_created_at).to_i,
      to: Time.now.utc.to_i
    }
  end
end
