# frozen_string_literal: true

class PurgeOldUserSessionsWorker
  include Sidekiq::Worker

  def perform
    return unless stale_sessions.exists?

    stale_sessions.select(:id).find_in_batches do |sessions|
      enqueue_sessions_in_batch(sessions)
    end
  end

  protected

  def stale_sessions
    UserSession.stale
  end

  def enqueue_sessions_in_batch(sessions)
    batch = Sidekiq::Batch.new
    batch.description = "UserSession sweeping #{sessions.first.id} to #{sessions.last.id}"

    batch.jobs do
      sessions.each do |session|
        UserSessionSweeperWorker.perform_async(session.id)
      end
    end
  end
end
