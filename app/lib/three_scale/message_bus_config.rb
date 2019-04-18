# frozen_string_literal: true

module ThreeScale
  class MessageBusConfig
    def initialize(message_bus_config = {})
      @config = message_bus_config.dup

      @enabled = config.delete(:enabled)
      @redis_config = build_redis_config(config.delete(:redis)) unless %i[memory postgres].include?(config[:backend]) # https://github.com/SamSaffron/message_bus/tree/v2.0.2/lib/message_bus/backends
    end

    attr_reader :config, :enabled, :redis_config

    def configure_message_bus!
      MessageBus.configure(config)
      MessageBus.redis_config = redis_config if redis_config.present?

      return MessageBus.off unless enabled

      MessageBus.timer.on_error do |error|
        System::ErrorReporting.report_error(error)
      end
      MessageBus.on_middleware_error do |env, error|
        System::ErrorReporting.report_error(error, rack_env: env)
      end
    end

    def self.build_redis_config(config)
      redis_config = (config || {}).symbolize_keys
      return redis_config if redis_config[:url].present?
      redis_config.delete(:url)

      # Uses default redis config in case message bus specific config has not 'url' or 'host' specified
      default_redis_config = System::Application.config.redis.symbolize_keys

      redis_config.reverse_merge!(default_redis_config)
      redis_config[:db] = next_db(redis_db_in(default_redis_config)) if key_collision_prone?(redis_config, default_redis_config) # Prevents key collision with different dbs is necessary
      redis_config
    end

    def self.key_collision_prone?(redis_config, default_redis_config)
      return false if redis_config[:namespace].presence != default_redis_config[:namespace].presence
      redis_db_in(redis_config) == redis_db_in(default_redis_config)
    end

    def self.redis_db_in(redis_config)
      db = redis_config[:db].presence
      return db.to_i if db
      url = redis_config[:url].presence
      return unless url
      URI.parse(url).path[1..-1].to_s.to_i
    end

    def self.next_db(redis_db)
      (redis_db+1)%16
    end

    delegate :build_redis_config, to: 'self.class'
  end
end
