# frozen_string_literal: true

module ThreeScale
  class RedisConfig
    def initialize(redis_config = {})
      raw_config = (redis_config || {}).symbolize_keys
      sentinels = raw_config.delete(:sentinels).presence
      disable_client_id = raw_config.delete(:disable_client_id).presence
      raw_config.delete_if { |key, value| value.blank? }

      @config = ActiveSupport::OrderedOptions.new.merge(raw_config)
      config.sentinels = parse_sentinels(sentinels) if sentinels

      # Disable CLIENT SETNAME, for Redis instances that don't support CLIENT command
      config.id = nil if disable_client_id
    end

    attr_reader :config

    def db
      value = config.db.presence
      return value.to_i if value
      url = config.url.presence
      return unless url
      URI.parse(url).path[1..-1].to_s.to_i
    end

    def prone_to_key_collision_with?(other)
      return false if config.namespace.presence != other.namespace.presence
      db == other.db
    end

    def rotate_db
      config.db = next_db
    end

    def reverse_merge(other)
      other.merge(config)
    end

    def reverse_merge!(other)
      @config = ActiveSupport::OrderedOptions.new.merge(reverse_merge(other))
    end

    def method_missing(method_sym, *args, &block)
      if config.respond_to?(method_sym)
        config.send(method_sym, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_sym, *args)
      super || config.respond_to?(method_sym)
    end

    protected

    DEFAULT_SENTINEL_PORT = 26379

    def parse_sentinels(sentinels)
      return unless sentinels
      sentinels.to_s.split(',').map do |sentinel_url|
        uri = URI.parse((sentinel_url =~ %r{^(redis(s)?|unix):\/\/.+} ? '' : 'redis://') + sentinel_url)
        parsed_sentinel = { host: uri.host, port: (uri.port || DEFAULT_SENTINEL_PORT) }
        password = uri.password
        parsed_sentinel[:password] = password if password
        parsed_sentinel
      end
    end

    def next_db
      (db + 1) % 16
    end
  end
end
