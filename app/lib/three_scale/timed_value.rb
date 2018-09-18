require 'redis'
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

  protected

  def self.redis
    Redis::Namespace.new(:timed_value, redis: System.redis)
  end

end
