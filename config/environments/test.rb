require "active_support/core_ext/integer/time"

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
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  # config.consider_all_requests_local       = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Store uploaded files on the local file system in a temporary directory
  # config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # WARNING: we can't enable it because it breaks some views that use `render_to_js_string`
  # config.action_view.annotate_rendered_view_with_filenames = true

  config.active_support.test_order = :random

  config.three_scale.payments.merge!(enabled: true, active_merchant_mode: :test, active_merchant_logging: false)

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

  config.asset_host = ->(source) do
    full_path = File.join(Rails.public_path, source)
    exist_in_public_assets = File.exist?(full_path)

    break unless exist_in_public_assets

    config.three_scale.asset_host.presence
  end

  config.after_initialize do
    ::GATEWAY = ActiveMerchant::Billing::BogusGateway.new
  end

  config.after_initialize do
    if defined?(Bullet)
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.raise = true

      # We ignore these items because they are broken at the time commit them but we should fix them, see
      # https://issues.redhat.com/browse/THREESCALE-9973
      Bullet.add_safelist class_name: "Account", type: :n_plus_one_query, association: :admin_user
      Bullet.add_safelist class_name: "Account", type: :n_plus_one_query, association: :bought_account_contract
      Bullet.add_safelist class_name: "Account", type: :n_plus_one_query, association: :bought_account_plan
      Bullet.add_safelist class_name: "Account", type: :n_plus_one_query, association: :provider_account
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :admin_user
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :admin_users
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :bought_cinstances
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :country
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :users
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :bought_plans
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :users
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :country
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :bought_plans
      Bullet.add_safelist class_name: "Account", type: :unused_eager_loading, association: :contracts
      Bullet.add_safelist class_name: "AccountContract", type: :n_plus_one_query, association: :plan
      Bullet.add_safelist class_name: "AccountPlan", type: :n_plus_one_query, association: :customizations
      Bullet.add_safelist class_name: "AccountPlan", type: :n_plus_one_query, association: :issuer
      Bullet.add_safelist class_name: "AccountPlan", type: :n_plus_one_query, association: :pricing_rules
      Bullet.add_safelist class_name: "AccountPlan", type: :unused_eager_loading, association: :original
      Bullet.add_safelist class_name: "Alert", type: :n_plus_one_query, association: :cinstance
      Bullet.add_safelist class_name: "ApiDocs::Service", type: :unused_eager_loading, association: :service
      Bullet.add_safelist class_name: "ApplicationPlan", type: :n_plus_one_query, association: :customizations
      Bullet.add_safelist class_name: "ApplicationPlan", type: :n_plus_one_query, association: :pricing_rules
      Bullet.add_safelist class_name: "ApplicationPlan", type: :n_plus_one_query, association: :usage_limits
      Bullet.add_safelist class_name: "ApplicationPlan", type: :unused_eager_loading, association: :issuer
      Bullet.add_safelist class_name: "ApplicationPlan", type: :unused_eager_loading, association: :pricing_rules
      Bullet.add_safelist class_name: "ApplicationPlan", type: :unused_eager_loading, association: :service
      Bullet.add_safelist class_name: "BackendApi", type: :counter_cache, association: :backend_api_configs
      Bullet.add_safelist class_name: "CMS::Builtin::Section", type: :n_plus_one_query, association: :children
      Bullet.add_safelist class_name: "CMS::Builtin::Section", type: :n_plus_one_query, association: :parent
      Bullet.add_safelist class_name: "CMS::File", type: :n_plus_one_query, association: :provider
      Bullet.add_safelist class_name: "CMS::Page", type: :n_plus_one_query, association: :provider
      Bullet.add_safelist class_name: "CMS::Page", type: :n_plus_one_query, association: :section
      Bullet.add_safelist class_name: "Cinstance", type: :n_plus_one_query, association: :plan
      Bullet.add_safelist class_name: "Cinstance", type: :n_plus_one_query, association: :service
      Bullet.add_safelist class_name: "Cinstance", type: :n_plus_one_query, association: :user_account
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :plan
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :service
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :service
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :service
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :plan
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :user_account
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :user_account
      Bullet.add_safelist class_name: "Cinstance", type: :unused_eager_loading, association: :service
      Bullet.add_safelist class_name: "Invoice", type: :counter_cache, association: :payment_transactions
      Bullet.add_safelist class_name: "Invoice", type: :n_plus_one_query, association: :buyer_account
      Bullet.add_safelist class_name: "Invoice", type: :n_plus_one_query, association: :provider_account
      Bullet.add_safelist class_name: "Invoice", type: :unused_eager_loading, association: :line_items
      Bullet.add_safelist class_name: "Invoice", type: :unused_eager_loading, association: :line_items
      Bullet.add_safelist class_name: "Invoice", type: :unused_eager_loading, association: :buyer_account
      Bullet.add_safelist class_name: "Invoice", type: :unused_eager_loading, association: :line_items
      Bullet.add_safelist class_name: "Invoice", type: :unused_eager_loading, association: :buyer_account
      Bullet.add_safelist class_name: "Invoice", type: :unused_eager_loading, association: :provider_account
      Bullet.add_safelist class_name: "Invoice", type: :unused_eager_loading, association: :provider_account
      Bullet.add_safelist class_name: "LineItem::PlanCost", type: :n_plus_one_query, association: :contract
      Bullet.add_safelist class_name: "Message", type: :n_plus_one_query, association: :sender
      Bullet.add_safelist class_name: "Metric", type: :n_plus_one_query, association: :children
      Bullet.add_safelist class_name: "Metric", type: :n_plus_one_query, association: :owner
      Bullet.add_safelist class_name: "Metric", type: :n_plus_one_query, association: :parent
      Bullet.add_safelist class_name: "Metric", type: :unused_eager_loading, association: :children
      Bullet.add_safelist class_name: "Metric", type: :unused_eager_loading, association: :owner
      Bullet.add_safelist class_name: "Metric", type: :unused_eager_loading, association: :owner
      Bullet.add_safelist class_name: "Metric", type: :unused_eager_loading, association: :parent
      Bullet.add_safelist class_name: "Metric", type: :unused_eager_loading, association: :parent
      Bullet.add_safelist class_name: "Post", type: :n_plus_one_query, association: :topic
      Bullet.add_safelist class_name: "ProxyConfig", type: :n_plus_one_query, association: :user
      Bullet.add_safelist class_name: "ProxyRule", type: :n_plus_one_query, association: :owner
      Bullet.add_safelist class_name: "Service", type: :counter_cache, association: :backend_api_configs
      Bullet.add_safelist class_name: "Service", type: :counter_cache, association: :cinstances
      Bullet.add_safelist class_name: "Service", type: :n_plus_one_query, association: :account
      Bullet.add_safelist class_name: "Service", type: :n_plus_one_query, association: :default_service_plan
      Bullet.add_safelist class_name: "Service", type: :n_plus_one_query, association: :metrics
      Bullet.add_safelist class_name: "Service", type: :unused_eager_loading, association: :application_plans
      Bullet.add_safelist class_name: "ServiceContract", type: :n_plus_one_query, association: :plan
      Bullet.add_safelist class_name: "ServiceContract", type: :n_plus_one_query, association: :user_account
      Bullet.add_safelist class_name: "ServicePlan", type: :n_plus_one_query, association: :customizations
      Bullet.add_safelist class_name: "ServicePlan", type: :n_plus_one_query, association: :issuer
      Bullet.add_safelist class_name: "ServicePlan", type: :n_plus_one_query, association: :pricing_rules
      Bullet.add_safelist class_name: "ServicePlan", type: :unused_eager_loading, association: :pricing_rules # Or features/buyers/accounts/service_contracts/index.feature:90 fails
      Bullet.add_safelist class_name: "ServicePlan", type: :n_plus_one_query, association: :service
      Bullet.add_safelist class_name: "Topic", type: :n_plus_one_query, association: :last_user
      Bullet.add_safelist class_name: "Topic", type: :n_plus_one_query, association: :recent_post
      Bullet.add_safelist class_name: "UsageLimit", type: :unused_eager_loading, association: :plan
      Bullet.add_safelist class_name: "UsageLimit", type: :unused_eager_loading, association: :plan
      Bullet.add_safelist class_name: "UsageLimit", type: :unused_eager_loading, association: :metric
      Bullet.add_safelist class_name: "User", type: :n_plus_one_query, association: :member_permissions
      Bullet.add_safelist class_name: "UserTopic", type: :n_plus_one_query, association: :topic
    end
  end

  # Make sure the middleware is inserted first in middleware chain
  require 'gitlab/testing/request_blocker_middleware'
  require 'gitlab/testing/request_inspector_middleware'
  config.middleware.insert_before ActionDispatch::Static, Gitlab::Testing::RequestBlockerMiddleware
  config.middleware.insert_before ActionDispatch::Static, Gitlab::Testing::RequestInspectorMiddleware
end
