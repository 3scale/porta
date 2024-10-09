require 'progress_counter'

class SidekiqBatchCleanupService
  MAX_FETCH_COUNT = 1000

  BID_EXPIRE_TTL = 2_592_000 # 30 days, default expiration for sidekiq batch keys
  BID_KEEP = 10_800 # 3 hours

  # Delete BIDs that have TTL less than 29 days 21 hours
  BID_MAX_TTL = BID_EXPIRE_TTL - BID_KEEP

  def initialize
    @now = Time.zone.now
    @redis = System.redis
  end

  attr_reader :now, :redis

  def call
    total = redis.dbsize
    Rails.logger.info "Total number of keys: #{total}"

    scan_enum = System.redis.scan_each(match: 'BID-*', type: 'hash', count: MAX_FETCH_COUNT)

    each_with_progress_counter(scan_enum, total) do |key|
      next if key =~ /-(success|complete|failed|jids)$/
      bid = key.remove(/^BID-/)
      perform(bid)
    end
  end
  
  def perform(bid)
    # TODO: ensure there is no task running still
    batch_key = "BID-#{bid}"
    ttl = redis.ttl(batch_key)

    if ttl <= BID_MAX_TTL
      Sidekiq::Batch.cleanup_redis(bid)
    end
  end

  private

  def each_with_progress_counter(enumerable, count)
    progress = ProgressCounter.new(count)
    enumerable.each do |element|
      yield element
      progress.call
    end
  end
end
