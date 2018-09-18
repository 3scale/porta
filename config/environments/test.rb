System::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Disable css/jquery animations in tests, makes percy much happier
  config.middleware.use Rack::NoAnimations

  config.eager_load = false # true if you use a tool to preload your test environment
  config.allow_concurrency = false

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  config.action_view.raise_on_missing_translations = true

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.representer.default_url_options = { host: 'example.org' }
  config.action_mailer.default_url_options = { host: 'example.org' }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  config.assets.compile = ENV.fetch('SKIP_ASSETS', '0') == '0'
  # NEEDS TESTING if it right value or not
  config.serve_static_files = true

  # Print deprecation notices to the stderr

  config.active_support.deprecation = :stderr
  config.active_support.test_order = :sorted # who feels brave can set it to :random

  config.three_scale.payments.enabled = true

  config.three_scale.rolling_updates.raise_error_unknown_features = true
  config.three_scale.rolling_updates.enabled = false

  config.after_initialize do
    ::GATEWAY = ActiveMerchant::Billing::BogusGateway.new
  end
end
