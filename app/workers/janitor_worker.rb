# frozen_string_literal: true

class JanitorWorker
  include Sidekiq::Worker

  def perform
    return unless ThreeScale.config.janitor_worker_enabled

    PurgeOldUserSessionsWorker.perform_async
    PurgeOldEventsWorker.perform_async
  end
end
