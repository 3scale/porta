# frozen_string_literal: true

module ThreeScale
  class RedisConfig
    def initialize(redis_config = {})
      raw_config = (redis_config || {}).deep_symbolize_keys
      raw_config.delete_if { |_key, value| value.blank? }
      parse_uri(raw_config)
      apply_sentinels_config!(raw_config)
      raw_config.compact!

      @config = ActiveSupport::OrderedOptions.new.merge(raw_config)
    end

    attr_reader :config

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

    def parse_uri(raw_config)
      uri = URI.parse(raw_config[:url].to_s)
      if uri.scheme == 'unix'
        raw_config[:path] ||= uri.path
        raw_config[:url] = nil
      else
        raw_config[:db] ||= uri.path[1..]
        raw_config[:ssl] ||= true if uri.scheme == 'rediss'
      end
    end

    def apply_sentinels_config!(config)
      sentinels = config.delete(:sentinels).presence
      return unless sentinels

      sentinel_user = nil
      sentinel_password = nil
      config[:sentinels] = sentinels.to_s.split(',').map do |sentinel_url|
        uri = URI.parse((sentinel_url =~ %r{^(redis(s)?|unix):\/\/.+} ? '' : 'redis://') + sentinel_url)
        sentinel_user ||= uri.user
        sentinel_password ||= uri.password
        { host: uri.host, port: (uri.port || DEFAULT_SENTINEL_PORT) }
      end

      config[:name] ||= URI.parse(config[:url].to_s).host
      config[:sentinel_username] = sentinel_user if sentinel_user.present?
      config[:sentinel_password] = sentinel_password if sentinel_password.present?

      config
    end
  end
end
