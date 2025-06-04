module System
  module RedisClientPool

    module_function

    def new_pool(config = System::Application.config.redis)
      redis_config = ThreeScale::RedisConfig.new(config)
      redis_client_config = RedisClient.config(**redis_config.client_config)
      redis_client_config.new_pool(**redis_config.pool_config)
    end
  end
end
