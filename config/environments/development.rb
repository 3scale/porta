# noinspection RubyResolve
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false
  config.enable_dependency_loading = true

  # Show full error reports.
  config.consider_all_requests_local = true
  config.assets.compile = true
  config.assets.digest = false
  config.assets.precompile += %w( spec_helper.js )

  config.asset_host = ->(*args) {
    _source, request = args

    return unless request
    request.headers['host']
  }

  config.middleware.insert_before ActionDispatch::Static, Rack::Deflater

  config.public_file_server.enabled = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.perform_deliveries = true

  config.action_mailer.delivery_method =
    if defined?(LetterOpener)
      :letter_opener
    elsif config.action_mailer.smtp_settings[:address]
      :smtp
    else
      :test
    end

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.three_scale.payments.enabled = ENV.fetch('THREESCALE_PAYMENTS_ENABLED', '0') == '1'

  config.three_scale.rolling_updates.raise_error_unknown_features = true
  config.three_scale.rolling_updates.enabled = ENV.fetch('THREESCALE_ROLLING_UPDATES', '0') == '0'

  config.action_mailer.default_url_options = { protocol: 'http' }
  config.representer.default_url_options = { protocol: 'http' }

  config.after_initialize do

    if defined?(Bullet)
      Bullet.enable = true
      Bullet.alert = false
      Bullet.bullet_logger = true
      Bullet.console = false
      #Bullet.growl = false
      #Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
      #                :password => 'bullets_password_for_jabber',
      #                :receiver => 'your_account@jabber.org',
      #                :show_online_status => true }
      Bullet.rails_logger = true
      #Bullet.honeybadger = true
      #Bullet.bugsnag = true
      #Bullet.airbrake = true
      #Bullet.rollbar = true
      #Bullet.add_footer = true
      #Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
      #Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
      #Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
    end
  end
end
