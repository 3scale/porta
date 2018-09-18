# noinspection RubyResolve
System::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.assets.debug = true
  config.assets.compile = true
  config.assets.digest = false
  config.assets.precompile += %w( spec_helper.js )

  config.asset_host = ->(*args) {
    _source, request = args

    return unless request
    request.headers['host']
  }

  config.serve_static_files = true

  config.middleware.insert_before ActionDispatch::Static, Rack::Deflater
  config.middleware.insert_before ActionDispatch::Static, Rack::Jspm

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_view.raise_on_missing_translations = true

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  # See emails in browser
  config.action_mailer.delivery_method = defined?(LetterOpener) ? :letter_opener : :test

  config.three_scale.payments.enabled = false

  config.three_scale.rolling_updates.raise_error_unknown_features = true
  config.three_scale.rolling_updates.enabled = ENV.fetch('THREESCALE_ROLLING_UPDATES', '0') == '0'

  config.action_mailer.default_url_options = { protocol: 'http' }
  config.representer.default_url_options = { protocol: 'http' }

  config.middleware.use ThreeScale::Middleware::DevDomain

  config.after_initialize do

    if defined?(Bullet)
      Bullet.enable = true
      Bullet.console = true
      Bullet.rails_logger = true
      Bullet.alert = false
      Bullet.console = false
    end
  end
end
