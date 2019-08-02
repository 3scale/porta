require File.expand_path('../boot', __FILE__)

require 'rails/all'
# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development production preview test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

ActiveSupport::XmlMini.backend = 'Nokogiri'

module System

  def self.rails4?
    raise 'does not accept block' if block_given?
    Rails::VERSION::MAJOR == 4
  end

  def self.rails4
    block_given? ? (rails4? && yield) : rails4?
  end

  module AssociationExtension
    def self.included(base)
      base.define_singleton_method(:to_proc) do
        lambda { |_| include base }
      end
    end
  end

  mattr_accessor :redis

  class Application < Rails::Application
    # The old config_for gem returns HashWithIndifferentAccess
    # https://github.com/3scale/config_for/blob/master/lib/config_for/config.rb#L16
    def config_for(*args)
      config = super
      config.is_a?(Hash) ? config.with_indifferent_access : config
    end

    config.active_job.queue_adapter = :sidekiq

    def simple_try_config_for(*args)
      config_for(*args)
    rescue => error # rubocop:disable Style/RescueStandardError
      warn "[Warning][ConfigFor] Failed to load config with: #{error}" if $VERBOSE
      nil
    end

    def try_config_for(*args)
      simple_try_config_for(*args)&.symbolize_keys
    end

    if ENV['RAILS_LOG_TO_STDOUT'].present?
      config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
    end

    # Disables Yarn check
    config.webpacker.check_yarn_integrity = false

    config.active_record.whitelist_attributes = false

    config.boot_time = Time.now

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root.join('lib')})

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    config.active_record.raise_in_transactional_callbacks = true

    # Activate observers that should always be running.
    config.active_record.observers = :account_observer,
                                     :message_observer,
                                     :billing_observer,
                                     :post_observer,
                                     :user_observer,
                                     :billing_strategy_observer,
                                     :provider_plan_change_observer,
                                     :plan_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    if (expansions = config.action_view.javascript_expansions)
      expansions[:defaults] = %w()
    end

    config.assets.paths << Rails.root.join('assets')
    config.assets.paths << Rails.root.join("lib", "liquid", "template", "buyer_side")
    config.assets.paths << Rails.root.join("vendor", "assets", "images")

    config.assets.enabled = true

    config.assets.precompile = []
    config.assets.precompile << ->(filename, _path) do
      basename = File.basename(filename)

      extname = File.extname(basename)

      # skip files that start with underscore, do not have extension or are sourcemap
      extname.present? && ! extname.in?(%w[.map .LICENSE .es6]) && ! basename.start_with?('_'.freeze)
    end
    config.assets.precompile += %w(
      font-awesome.css
      provider/signup_v2.js
      provider/signup_form.js
      provider/layout/provider.js
    )

    config.assets.compile = false
    config.assets.digest = true
    config.assets.initialize_on_precompile = false

    config.assets.version = '1437647386' # unix timestamp


    config.serve_static_files = false

    # We don't want Rack::Cache to be used
    config.action_dispatch.rack_cache = false

    config.cache_store = config_for(:cache_store)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.web_hooks = ActiveSupport::OrderedOptions.new
    config.web_hooks.merge!(config_for(:web_hooks).symbolize_keys)

    config.liquid = ActiveSupport::OrderedOptions.new
    config.liquid.resolver_caching = false

    config.representer.default_url_options = { protocol: 'https' }


    config.zync = ActiveSupport::InheritableOptions.new(try_config_for(:zync))

    config.three_scale = ActiveSupport::OrderedOptions.new
    config.three_scale.core = ActiveSupport::OrderedOptions.new

    config.three_scale.payments = ActiveSupport::OrderedOptions.new
    config.three_scale.rolling_updates = ActiveSupport::OrderedOptions.new
    config.three_scale.email_sanitizer = ActiveSupport::OrderedOptions.new
    config.three_scale.sandbox_proxy = ActiveSupport::OrderedOptions.new
    config.three_scale.sandbox_proxy.merge!(config_for(:sandbox_proxy).symbolize_keys)

    config.three_scale.web_analytics = ActiveSupport::OrderedOptions.new
    config.three_scale.tracking = ActiveSupport::OrderedOptions.new
    config.three_scale.mixpanel = ActiveSupport::OrderedOptions.new
    config.three_scale.mixpanel.merge!(config_for(:mixpanel).symbolize_keys)
    config.three_scale.core.merge!(config_for(:core).symbolize_keys)
    config.three_scale.web_analytics.merge!(config_for(:web_analytics).deep_symbolize_keys)

    config.three_scale.segment = ActiveSupport::OrderedOptions.new
    config.three_scale.segment.merge!(config_for(:segment).symbolize_keys)

    config.three_scale.google_experiments = ActiveSupport::OrderedOptions.new
    config.three_scale.google_experiments.enabled = false
    config.three_scale.google_experiments.merge!(config_for(:google_experiments).symbolize_keys)

    config.three_scale.redhat_customer_portal = ActiveSupport::OrderedOptions.new
    config.three_scale.redhat_customer_portal.enabled = false
    config.three_scale.redhat_customer_portal.merge!(try_config_for(:redhat_customer_portal) || {})

    config.three_scale.payments.enabled = false
    config.three_scale.active_merchant_mode ||= Rails.env.production? ? :production : :test

    config.three_scale.rolling_updates.features = try_config_for(:rolling_updates)

    config.three_scale.service_discovery = ActiveSupport::OrderedOptions.new
    config.three_scale.service_discovery.enabled = false
    config.three_scale.service_discovery.merge!(try_config_for(:service_discovery) || {})

    config.three_scale.plan_rules = ActiveSupport::OrderedOptions.new
    config.three_scale.plan_rules.merge!(try_config_for(:plan_rules) || {})

    config.three_scale.features = ActiveSupport::OrderedOptions.new
    config.three_scale.features.merge!(try_config_for(:features) || {})

    config.three_scale.prometheus = ActiveSupport::OrderedOptions.new
    config.three_scale.prometheus.merge!(try_config_for(:prometheus) || {})

    config.three_scale.message_bus = ActiveSupport::OrderedOptions.new
    config.three_scale.message_bus.merge!(try_config_for(:message_bus) || {})

    three_scale = config_for(:settings).symbolize_keys
    three_scale[:error_reporting_stages] = three_scale[:error_reporting_stages].to_s.split(/\W+/)

    email_sanitizer_configs = (three_scale.delete(:email_sanitizer) || {}).symbolize_keys
    config.three_scale.email_sanitizer.merge!(email_sanitizer_configs)

    config.three_scale.merge!(three_scale.slice!(:force_ssl, :access_code))
    three_scale.each do |key, val|
      config.public_send("#{key}=", val)
    end

    config.action_mailer.default_url_options = { protocol: 'https' }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = smtp_config = (try_config_for(:smtp) || { })
    config.action_mailer.raise_delivery_errors = smtp_config[:address].present?

    config.cms_files_path = ':url_root/:date_partition/:basename-:random_secret.:extension'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += %i[activation_code cms_token credit_card credit_card_auth_code
                                   credit_card_authorize_net_payment_profile_token credit_card_expires_on
                                   credit_card_partial_number crypted_password janrain_api_key lost_password_token
                                   password password_digest payment_gateway_options payment_service_reference salt
                                   site_access_code sso_key user_key]

    require 'three_scale/middleware/multitenant'
    require 'three_scale/middleware/dev_domain'
    config.middleware.use ThreeScale::Middleware::Multitenant, :tenant_id
    config.middleware.use ThreeScale::Middleware::DevDomain, config.three_scale.dev_domain_regexp, config.three_scale.dev_domain_replacement if config.three_scale.dev_domain
    config.middleware.insert_before Rack::Runtime, Rack::UTF8Sanitizer
    config.middleware.insert_before Rack::Runtime, Rack::XServedBy # we can pass hashed hostname as parameter

    config.unicorn  = ActiveSupport::OrderedOptions[after_fork: []]
    config.unicorn.after_fork << MessageBus.method(:after_fork)

    config.action_dispatch.cookies_serializer = :hybrid

    initializer :load_configs, before: :load_config_initializers do
      config.backend_client = { max_tries: 5 }.merge(config_for(:backend).symbolize_keys)
      config.redis = config.sidekiq = config_for(:redis)
      config.s3 = config_for(:amazon_s3)
      config.three_scale.oauth2 = config_for(:oauth2)
    end

    initializer :log_formatter, after: :initialize_logger do
      config.log_formatter = System::ErrorReporting::LogFormatter.new
      (config.logger || Rails.logger).formatter = config.log_formatter
    end

    config.paperclip_defaults = {
        storage: :s3,
        s3_credentials: ->(*) { CMS::S3.credentials },
        bucket: ->(*) { CMS::S3.bucket },
        s3_protocol: 'https'.freeze,
        s3_permissions: 'private'.freeze,
        s3_region: ->(*) { CMS::S3.region },
        url: ':storage_root/:class/:id/:attachment/:style/:basename.:extension'.freeze,
        path: ':rails_root/public/system/:url'.freeze
    }.merge(try_config_for(:paperclip) || {})

    config.after_initialize do
      require 'three_scale'
      ThreeScale.validate_settings!
      require 'system/redis_pool'
      redis_config = ThreeScale::RedisConfig.new(config.redis)
      System.redis = System::RedisPool.new(redis_config.config)
    end

    config.assets.quiet = true

    initializer :jobs do
      # Loading jobs used by Whenever
      require_relative 'jobs'
    end

    console do
      if sandbox?
        puts <<-WARNING.strip_heredoc
\e[5;37;41m
YOU ARE USING SANDBOX MODE. DO NOT MODIFY RECORDS! THIS IS DANGEROUS AS IT WILL LOCK TABLES!
See https://github.com/3scale/system/issues/6616
\e[0m
        WARNING
      end
    end
  end
end

# FIXME: we should cleanup our state machines and remove this
StateMachines::Machine.ignore_method_conflicts = true
