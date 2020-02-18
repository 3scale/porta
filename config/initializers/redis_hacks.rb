# frozen_string_literal: true

# Monkey patches redis-db so sentinel passwords are supported
# See https://github.com/redis/redis-rb/pull/856
# We can remove this once we can upgrade the gem to >= v4.1.2

module RedisHacks
  def sentinel_detect
    @sentinels.each do |sentinel|
      client = Redis::Client.new(@options.merge({
        :host => sentinel[:host],
        :port => sentinel[:port],
        :password => sentinel[:password], # https://github.com/redis/redis-rb/pull/856
        :reconnect_attempts => 0,
      }))

      begin
        if result = yield(client)
          # This sentinel responded. Make sure we ask it first next time.
          @sentinels.delete(sentinel)
          @sentinels.unshift(sentinel)

          return result
        end
      rescue Redis::BaseConnectionError
      rescue RuntimeError => exception
        raise unless exception.message =~ /Name or service not known/
      ensure
        client.disconnect
      end
    end

    raise CannotConnectError, "No sentinels available."
  end
end

Redis::Client::Connector::Sentinel.prepend(RedisHacks)
