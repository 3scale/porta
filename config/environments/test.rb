Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = !Kernel.const_defined?(:Spring)
  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.seconds.to_i}"
  }

  # Show full error reports and disable caching.
  # config.consider_all_requests_local       = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  config.active_support.test_order = :sorted # who has the balls can set it to :random

  config.three_scale.payments.enabled = true
  config.three_scale.active_merchant_mode = :test
  config.three_scale.active_merchant_logging = false

  config.three_scale.rolling_updates.raise_error_unknown_features = true
  config.three_scale.rolling_updates.enabled = false
  config.representer.default_url_options = { host: 'example.org' }
  config.action_mailer.default_url_options = { host: 'example.org' }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql


  # Disable css/jquery animations in tests
  # TODO: remove in favor of Capybara.disable_animation = true when we upgrade to capybara 3
  config.middleware.use Rack::NoAnimations

  config.assets.compile = ENV.fetch('SKIP_ASSETS', '0') == '0'

  config.after_initialize do
    ::GATEWAY = ActiveMerchant::Billing::BogusGateway.new
  end

  # Make sure the middleware is inserted first in middleware chain
  require 'gitlab/testing/request_blocker_middleware'
  require 'gitlab/testing/request_inspector_middleware'
  config.middleware.insert_before ActionDispatch::Static, Gitlab::Testing::RequestBlockerMiddleware
  config.middleware.insert_before ActionDispatch::Static, Gitlab::Testing::RequestInspectorMiddleware
end
