# frozen_string_literal: true

require 'progress_counter'

module ThreeScale
  class SidekiqBatchCleanupService < ThreeScale::Patterns::Service
    MAX_FETCH_COUNT = 1000

    DEFAULT_MAX_AGE_SECONDS = 3.hours.seconds

    # `max_age_seconds` specifies the maximum age of the keys (in seconds)
    # all keys that are older will be deleted, calculated by the TTL that is still left, compared with the default expire value
    def initialize(max_age_seconds: DEFAULT_MAX_AGE_SECONDS)
      raise ArgumentError, "max_age_seconds must be greater than zero" if max_age_seconds.negative?
      raise ArgumentError, "max_age_seconds must be less than #{Sidekiq::Batch::BID_EXPIRE_TTL} seconds" if max_age_seconds >= Sidekiq::Batch::BID_EXPIRE_TTL

      @bid_max_ttl = Sidekiq::Batch::BID_EXPIRE_TTL - max_age_seconds

      @now = Time.zone.now
      @redis = System.redis
      super()
    end

    attr_reader :now, :redis, :bid_max_ttl

    def call
      total = redis.dbsize
      logger.info "Total number of keys: #{total}, will delete BID-* keys with TTL less than #{bid_max_ttl_to_s}"

      scan_enum = System.redis.scan_each(match: 'BID-*', type: 'hash', count: MAX_FETCH_COUNT)

      each_with_progress_counter(scan_enum, total) do |key|
        next if /-(success|complete|failed|jids)$/.match?(key)

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

    # print bid_max_ttl in format "1 hours 30 minutes 10 seconds"
    def bid_max_ttl_to_s
      ActiveSupport::Duration.build(bid_max_ttl).parts.reduce("") { |str, (period,value) | "#{str} #{value} #{period}" }
    end

    def logger
      @logger ||= ProgressCounter.stdout_logger
    end
  end
end
