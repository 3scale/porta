# frozen_string_literal: true

module Events

  mattr_accessor :shared_secret

  def self.async_fetch_backend_events!
    EventsFetchWorker.enqueue
  end

  def self.fetch_backend_events!(events = ThreeScale::Core::Event.load_all)
    Rails.logger.info("Started fetching events from backend")

    Events::Importer.clear_services_cache

    events.each do |event|
      PersistEventWorker.enqueue(event.attributes)
    end

    unless events.empty?
      last_event = events.last
      last_id    = last_event.id
      delete_events_from_backend_until!(last_id)
    end

    Rails.logger.info("Finished fetching events from backend")
  end

  def self.delete_events_from_backend_until!(last_id)
    ThreeScale::Core::Event.delete_upto(last_id)
  end
end
