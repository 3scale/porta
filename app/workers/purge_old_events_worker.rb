# frozen_string_literal: true

class PurgeOldEventsWorker
  include Sidekiq::Worker

  def perform
    EventStore::Event.stale.find_each(&DeletePlainObjectWorker.method(:perform_later))
  end
end
