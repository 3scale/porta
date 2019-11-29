# frozen_string_literal: true

module ThreeScale
  class MessageBusConfig
    def initialize(message_bus_config = {})
      @config = message_bus_config.dup

      @enabled = config.delete(:enabled)

      return unless using_redis?

      redis_config = RedisConfig.new(config.delete(:redis))
      @redis_config = setup_redis_config(redis_config)
    end

    attr_reader :config, :enabled, :redis_config

    def configure_message_bus!
      MessageBus.configure(config)
      MessageBus.redis_config = redis_config.config if redis_config.present?

      return MessageBus.off unless enabled

      MessageBus.timer.on_error do |error|
        System::ErrorReporting.report_error(error)
      end
      MessageBus.on_middleware_error do |_, error|
        System::ErrorReporting.report_error(error)
      end
    end

    def using_redis?
      # https://github.com/SamSaffron/message_bus/tree/v2.0.2/lib/message_bus/backends
      !%i[memory postgres].include?(config[:backend])
    end

    def self.setup_redis_config(redis_config)
      return redis_config if redis_config.url.present?

      # Uses default redis config in case message bus specific config has not 'url' or 'host' specified
      default_redis_config = RedisConfig.new(System::Application.config.redis)

      redis_config.reverse_merge!(default_redis_config)
      redis_config.rotate_db while redis_config.prone_to_key_collision_with?(default_redis_config) # Prevents key collision with different dbs if necessary
      redis_config
    end

    delegate :setup_redis_config, to: 'self.class'
  end
end
