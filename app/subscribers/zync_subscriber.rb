# frozen_string_literal: true

class ZyncSubscriber < AfterCommitSubscriber

  def initialize(job = ZyncWorker)
    @job = job
    freeze
  end

  attr_reader :job

  # @param [ZyncEvent] event
  def after_commit(event)
    job.perform_async(event.event_id, event.data) unless event.skip_background_sync?
  end
end
