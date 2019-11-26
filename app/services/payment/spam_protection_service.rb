# frozen_string_literal: true

module Payment
  class SpamProtectionService
    MAX_REQUESTS_IN_A_PERIOD = 10

    def initialize(account, payment_status, user_session = nil)
      @account         = account
      @payment_status  = payment_status
      @gateway_setting = account.gateway_setting
      @user_session    = user_session
    end

    def call
      increment_total_requests
      return if payment_successful?

      Account.transaction do
        gateway_setting.increment_failure_count
        return unless gateway_setting.failure_higher_than_threshold?

        account.force_suspend!
        user_session&.revoke!
      end
    end

    def spamming?
      total_requests > MAX_REQUESTS_IN_A_PERIOD
    end

    private

    attr_accessor :account, :gateway_setting, :payment_status, :user_session

    def increment_total_requests
      redis.incr(key)
      redis.expire(key, 1.hour)
    end

    def total_requests
      redis.get(key).to_i
    end

    def key
      "#{@account.id}_payment_requests"
    end

    def payment_successful?
      payment_status
    end

    def redis
      @redis ||= Redis::Namespace.new(:payment_requests, redis: System.redis)
    end
  end
end
