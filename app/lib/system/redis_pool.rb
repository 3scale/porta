# frozen_string_literal: true

require 'connection_pool'

module System
  # RedisPool a simple wrapper around Redis with connection pooling
  class RedisPool

    def initialize(config = {})
      cfg = config.to_h
      pool_config = cfg.extract!(:size, :pool_timeout)
      @pool = ConnectionPool.new(size: pool_config[:size] || 5, timeout: pool_config[:pool_timeout] || 5 ) do
        redis_config = cfg.key?(:sentinels) ? RedisClient.sentinel(**cfg) : RedisClient.config(**cfg)
        redis_config.new_client
      end
    end

    # This class only respond to public methods of redis-client
    def respond_to_missing?(method_sym, _include_private = false)
      @pool.respond_to?(method_sym, false)
    end

    # This is used by some libraries, for example, Redlock
    def with(...)
      @pool.with(...)
    end

    def method_missing(...)
      @pool.with do |conn|
        conn.call(...)
      end
    end
  end
end
