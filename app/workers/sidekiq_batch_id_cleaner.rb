# frozen_string_literal: true

class SidekiqBatchIdCleaner < ApplicationJob

  KEEP_TTL = 3.days

  def perform(bid)
    # TODO: ensure there is no task running still
    batch_key = "BID-#{bid}"
    now = Time.zone.now
    timestamp = System.redis.hget(batch_key, 'created_at')
    created_at = timestamp ? Time.zone.at(timestamp.to_f) : now

    # Keep batches for 3 days
    return if created_at > now - KEEP_TTL

    Sidekiq::Batch.cleanup_redis(bid)
  end

  class Enqueuer < ApplicationJob

    MAX_FETCH_COUNT = 1000

    def perform(*)
      System.redis.scan_each match: 'BID-*', count: MAX_FETCH_COUNT do |key|
        next if key =~ /-(success|complete|failed|jids)$/
        SidekiqBatchIdCleaner.perform_later key.remove(/^BID-/)
      end
    end

  end

end
