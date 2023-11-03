# frozen_string_literal: true

# Monkey patches redis-rb so connections errors with exception class `RuntimeError` and
# message "Name or service not known" (i.e. name solving problems) are properly handled
# as `Redis::BaseConnectionError` errors, which will be caught by `Redis::Client#establish_connection`

module RedisHacks
  module HiredisConnection
    def connect(*args)
      super
    rescue RuntimeError => exception
      if exception.message =~ /(can't resolve)|(name or service not known)|(nodename nor servname provided, or not known)/i
        raise Redis::BaseConnectionError.new(exception.message)
      else
        raise
      end
    end
  end
end

Redis::Connection::Hiredis.singleton_class.prepend(RedisHacks::HiredisConnection)
