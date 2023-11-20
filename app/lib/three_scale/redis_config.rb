# frozen_string_literal: true

module ThreeScale
  class RedisConfig
    def initialize(redis_config = {})
      raw_config = (redis_config || {}).deep_symbolize_keys
      sentinels = raw_config.delete(:sentinels).presence
      raw_config.delete_if { |key, value| value.blank? }
      raw_config[:size] ||= raw_config.delete(:pool_size) if raw_config.key?(:pool_size)

      load_default_ca_cert(raw_config)

      @config = ActiveSupport::OrderedOptions.new.merge(raw_config)
      config.sentinels = parse_sentinels(sentinels) if sentinels
    end

    attr_reader :config

    def db
      value = config.db.presence
      return value.to_i if value
      url = config.url.presence
      return unless url
      URI.parse(url).path[1..-1].to_s.to_i
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

    def load_default_ca_cert(conf)
      return if conf.dig(:ssl_params, :ca_file).present? || conf.dig(:ssl_params, :ca_path).present?

      cert_path = Rails.root.join('config/ca_cert.pem').to_s

      return unless File.exist?(cert_path)

      conf[:ssl_params] ||= {}
      conf[:ssl_params][:ca_file] = cert_path
    end
  end
end
