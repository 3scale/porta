# frozen_string_literal: true

module DeadlockRetryable
  extend ActiveSupport::Concern

  DEADLOCK_MAX_RETRIES = 3

  private

  def with_deadlock_retry
    retries = 0
    begin
      yield
    rescue ActiveRecord::Deadlocked
      retries += 1
      raise if retries > DEADLOCK_MAX_RETRIES
      logger.warn("Deadlock detected (attempt #{retries}/#{DEADLOCK_MAX_RETRIES}), retrying")
      sleep(rand * 0.05)
      retry
    end
  end
end
