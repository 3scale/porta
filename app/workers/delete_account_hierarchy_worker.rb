# frozen_string_literal: true

class DeleteAccountHierarchyWorker < DeleteObjectHierarchyWorker
  include Sidekiq::Throttled::Job

  CONCURRENCY_LIMIT_KEY = "stale_deletion:concurrency_limit"
  DEFAULT_CONCURRENCY_LIMIT = 3

  sidekiq_throttle concurrency: {
    limit: ->(*) { (value = Sidekiq.redis { |c| c.get(CONCURRENCY_LIMIT_KEY) }) ? value.to_i : DEFAULT_CONCURRENCY_LIMIT },
    ttl: 1.hour.to_i
  }

  class << self
    def concurrency_limit
      (value = Sidekiq.redis { |c| c.get(CONCURRENCY_LIMIT_KEY) }) ? value.to_i : DEFAULT_CONCURRENCY_LIMIT
    end

    def concurrency_limit=(value)
      Sidekiq.redis { |c| c.set(CONCURRENCY_LIMIT_KEY, value.to_i) }
    end
  end
end
