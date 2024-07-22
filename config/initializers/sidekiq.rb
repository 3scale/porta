# frozen_string_literal: true

require 'three_scale/sidekiq_retry_support'
require 'three_scale/sidekiq_logging_middleware'

REDIS_PARAMS_WHITELIST = %i[username password db id timeout read_timeout write_timeout connect_timeout ssl
                            custom ssl_params driver protocol client_implementation command_builder inherit_socket
                            reconnect_attempts middlewares circuit_breaker sentinels sentinel_password
                            sentinel_username role name url].freeze

def sanitize_redis_config(cfg)
  cfg.slice(*REDIS_PARAMS_WHITELIST)
end

Sidekiq::Client.try(:reliable_push!) unless Rails.env.test?

Rails.application.config.to_prepare do
  Sidekiq.configure_server do |config|
    config.try(:reliable!)

    config.redis = sanitize_redis_config(ThreeScale::RedisConfig.new(System::Application.config.redis).config)

    config.logger.formatter = Sidekiq::Logger::Formatters::Pretty.new

    config.server_middleware do |chain|
      chain.add ThreeScale::Analytics::SidekiqMiddleware
      chain.add ThreeScale::SidekiqRetrySupport::Middleware
    end

    faraday = ThreeScale::Core.faraday
    faraday.options.timeout = 30
    faraday.options.open_timeout = 10

    schedule_file = Rails.root.join('config', 'sidekiq_schedule.yml')

    if File.exist?(schedule_file) && Sidekiq.server?
      Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
    end
    # This will start a webrick server in another thread
    # where the Sidekiq processes are spawned
    # So if we have multiple processes, then they should listen to different ports
    # Use PROMETHEUS_EXPORTER_BIND and PROMETHEUS_EXPORTER_PORT
    # if no PROMETHEUS_EXPORT_PORT given, it will start the server with default port 9394 + index
    port = ENV.fetch('PROMETHEUS_EXPORTER_PORT', 9394).to_i
    port += Sidekiq.default_configuration[:index].to_i
    ENV['PROMETHEUS_EXPORTER_PORT'] ||= port.to_s

    require 'yabeda/prometheus/mmap'

    Yabeda::Prometheus::Exporter.start_metrics_server!
  end
end

Rails.application.config.to_prepare do
  Sidekiq.configure_client do |config|
    config.redis = sanitize_redis_config(ThreeScale::RedisConfig.new(System::Application.config.redis).config)

    config.client_middleware do |chain|
      chain.add ThreeScale::SidekiqLoggingMiddleware
    end
  end
end
