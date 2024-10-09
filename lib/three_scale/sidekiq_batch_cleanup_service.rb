require 'progress_counter'

module ThreeScale
  class SidekiqBatchCleanupService
    MAX_FETCH_COUNT = 1000
  
    BID_EXPIRE_TTL = 2_592_000 # 30 days, default expiration for sidekiq batch keys
    DEFAULT_MAX_AGE_SECONDS = 10_800 # 3 hours
  
    # `max_age_seconds` specifies the maximum age of the keys (in seconds)
    # all keys that are older will be deleted, calculated by the TTL that is still left, compared with the default expire value
    def initialize(max_age_seconds: DEFAULT_MAX_AGE_SECONDS)
      @now = Time.zone.now
      @redis = System.redis
  
      @bid_max_ttl = BID_EXPIRE_TTL - max_age_seconds
    end
  
    attr_reader :now, :redis, :bid_max_ttl
  
    def call
      total = redis.dbsize
      Rails.logger.info "Total number of keys: #{total}, will delete keys with TTL less than #{bid_max_ttl.seconds.in_hours} hours"
  
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
  
      if ttl <= bid_max_ttl
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
end
