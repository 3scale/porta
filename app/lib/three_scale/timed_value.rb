# frozen_string_literal: true

class ThreeScale::TimedValue

  def self.get(key)
    redis.get(key)
  rescue Redis::CannotConnectError, Errno::EINVAL => error
    System::ErrorReporting.report_error(error)
  end

  def self.set(key, value, expire_in_secs = 60*10)
    redis.set(key, value)
    redis.expire(key, expire_in_secs)
  end

  class << self
    protected

    def redis
      System.redis
    end
  end
end
