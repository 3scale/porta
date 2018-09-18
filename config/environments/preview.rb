System::Application.configure do

  config.eager_load = true

  config.active_record.dump_schema_after_migration = false
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'debug').downcase.to_sym

  config.cache_classes = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.action_mailer.perform_deliveries = true
  config.active_support.deprecation = :notify

  # ip spoofing checks are pointless and might mess up proxies
  config.action_dispatch.ip_spoofing_check = false

  config.assets.compile = true
  config.assets.compress = true
  config.assets.digest = true

  config.asset_host = proc { |_source, request = nil| request && request.headers["X-Forwarded-For-Domain"] }

  config.serve_static_files = true
  config.middleware.insert_before ActionDispatch::Static, Rack::Deflater

  config.log_tags = [ :uuid, :host, :remote_ip ]

  config.liquid.resolver_caching = true

  config.three_scale.payments.enabled = false

  config.three_scale.rolling_updates.raise_error_unknown_features = false
  config.three_scale.rolling_updates.enabled = ENV.fetch('THREESCALE_ROLLING_UPDATES', '0') == '0'
end
