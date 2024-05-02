class PersistEventWorker
  include Sidekiq::Job

  def self.enqueue(event_attrs)
    perform_async(event_attrs.as_json)
  end

  def perform(event_attrs)
    backend_event = BackendEvent.new
    backend_event.data = event_attrs
    backend_event.id = event_attrs.symbolize_keys[:id]
    backend_event.save!
    Events::Importer.async_import_event!(event_attrs)
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.warn("PersistEventWorker: duplicated event #{event_attrs}, #{e.message}")
  end
end
