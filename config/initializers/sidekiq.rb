# frozen_string_literal: true

require 'three_scale/sidekiq_retry_support'
require 'three_scale/sidekiq_logging_middleware'
require 'sidekiq/throttled'

Sidekiq::Throttled.setup!

Sidekiq::Client.try(:reliable_push!) unless Rails.env.test?

Sidekiq.configure_server do |config|
  config.try(:reliable!)

  config.redis = ThreeScale::RedisConfig.new(System::Application.config.sidekiq).config
  config.error_handlers << System::ErrorReporting.method(:report_error)

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
  port += Sidekiq.options[:index].to_i
  ENV['PROMETHEUS_EXPORTER_PORT'] ||= port.to_s

  require 'yabeda/prometheus/mmap'

  Yabeda::Prometheus::Exporter.start_metrics_server!
end

Sidekiq.configure_client do |config|
  config.redis = ThreeScale::RedisConfig.new(System::Application.config.sidekiq).config

  config.client_middleware do |chain|
    chain.add ThreeScale::SidekiqLoggingMiddleware
  end
end
