module System
  module RedisClientPool

    module_function

    def new_pool(config = System::Application.config.redis)
      redis_config = ThreeScale::RedisConfig.new(config)
      client_config = redis_config.client_config
      redis_client_config = client_config.key?(:sentinels) ? RedisClient.sentinel(**client_config) : RedisClient.config(**client_config)
      redis_client_config.new_pool(**redis_config.pool_config)
    end

    def default
      @default_pool ||= new_pool
    end
  end
end
