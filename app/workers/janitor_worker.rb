# frozen_string_literal: true

class JanitorWorker
  include Sidekiq::Worker

  def perform
    return unless ThreeScale.config.janitor_worker_enabled

    PurgeOldUserSessionsWorker.perform_async
    PurgeStaleObjectsWorker.perform_later(*%w[EventStore::Event Alert DeletedObject])
  end
end
