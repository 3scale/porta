# frozen_string_literal: true

class ActionLimiter
  class ActionLimitsExceededError < StandardError
    def initialize(*)
      super("Rate limit exceeded")
    end
  end

  TIME_SPAN = 1.hour
  BUCKET_INTERVAL = 10.minutes
  THRESHOLD = 10

  # @param object [GlobalID object] It can be a User or an Account for example
  #   Needs to respond to to_global_id_param
  # @option threshold [Integer] Maximum number of actions to be performed.
  #   Default 10
  # @option interval [Integer] Interval in seconds for each time bucket.
  #   Default 600 seconds
  # @option timespan [Integer] Total size of the buckets in seconds.
  #
  def initialize(object, threshold: THRESHOLD, interval: BUCKET_INTERVAL, timespan: TIME_SPAN)
    subject = object.to_gid_param
    @threshold = threshold
    @timespan = timespan
    # REDIS CLIENT MIGRATION BLOCKER: `ratelimit` gem relies on `redis` and doesn't support `redis-client` or `connection_pool`
    @limiter = ::Ratelimit.new(subject, bucket_span: timespan, bucket_interval: interval, redis: System.redis)
  end

  # Pass a block to perform
  # @yield
  #   limiter = ActionLimiter.new(User.current_guest)
  #   limiter.perform! 'signup' do
  #     UserSignup.create(user_params)
  #   end
  def perform!(action, &block)
    @limiter.add(action)
    raise ActionLimitsExceededError if @limiter.exceeded?(action, threshold: @threshold, interval: @timespan)
    yield if block_given?
  end

  def perform(action, &block)
    perform!(action, &block)
  rescue Redis::BaseError => e
    System::ErrorReporting.report_error(e)
  end
end
