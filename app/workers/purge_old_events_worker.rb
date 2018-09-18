# frozen_string_literal: true

class PurgeOldEventsWorker
  include Sidekiq::Worker

  def perform
    batch = Sidekiq::Batch.new
    batch.description = 'Purge old events'

    batch.jobs do
      EventStore::Event.stale.find_each(&DeletePlainObjectWorker.method(:perform_later))
    end
  end
end
