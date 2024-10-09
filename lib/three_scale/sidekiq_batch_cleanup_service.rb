require 'progress_counter'

require 'three_scale/patterns/service'

module ThreeScale
  class SidekiqBatchCleanupService < ThreeScale::Patterns::Service
    MAX_FETCH_COUNT = 1000

    BID_EXPIRE_TTL = 30.days.seconds
    DEFAULT_MAX_AGE_SECONDS = 3.hours.seconds

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
      logger.info "Total number of keys: #{total}, will delete BID-* keys with TTL less than #{bid_max_ttl.seconds.in_hours} hours"

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

      Sidekiq::Batch.cleanup_redis(bid) if ttl <= bid_max_ttl
    end

    private

    def each_with_progress_counter(enumerable, count)
      progress = ProgressCounter.new(count)
      enumerable.each do |element|
        yield element
        progress.call
      end
    end

    def logger
      @logger ||= ProgressCounter.stdout_logger
    end
  end
end
