# frozen_string_literal: true

class JanitorWorker
  include Sidekiq::Job

  def perform
    return unless ThreeScale.config.janitor_worker_enabled

    PurgeOldUserSessionsWorker.perform_async
    PurgeStaleObjectsWorker.perform_later("EventStore::Event", "DeletedObject")
    DeleteAllStaleObjectsWorker.perform_later("MessageRecipient", "Message")

    true
  end
end
