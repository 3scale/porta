# frozen_string_literal: true

require 'connection_pool'

module System
  # RedisPool a simple wrapper around Redis with connection pooling
  class RedisPool

    # @param [Hash] config - configuration, as in config/redis.yml
    def initialize(config = {})
      redis_config = ThreeScale::RedisConfig.new(config)
      @pool = ConnectionPool.new(**redis_config.pool_config) do
        Redis.new(redis_config.client_config)
      end
    end

    # This class only respond to public methods of Redis
    def respond_to_missing?(method_sym, _include_private = false)
      @pool.with do |conn|
        conn.respond_to?(method_sym, false)
      end
    end

    def method_missing(...)
      @pool.with do |conn|
        conn.public_send(...)
      end
    end
  end
end
