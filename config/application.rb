require_relative 'boot'

require 'rails/all'

# If you precompile assets before deploying to production, use this line
Bundler.require(*Rails.groups(:assets => %w[development production preview test]))
# If you want your assets lazily compiled in production, use this line
# Bundler.require(:default, :assets, Rails.env)

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
        ->(_) { include base }
      end
    end
  end

  mattr_accessor :redis

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # The old config_for gem returns HashWithIndifferentAccess
    # https://github.com/3scale/config_for/blob/master/lib/config_for/config.rb#L16
    def config_for(*args)
      config = super
      config.is_a?(Hash) ? config.with_indifferent_access : config
    end

    config.active_job.queue_adapter = :sidekiq

    def simple_try_config_for(*args)
      config_for(*args)
    rescue => exception # rubocop:disable Style/RescueStandardError
      warn "[Warning][ConfigFor] Failed to load config with: #{exception}" if $VERBOSE
      nil
    end

    def try_config_for(*args)
      simple_try_config_for(*args)&.symbolize_keys
    end

    config.before_eager_load do
      require 'three_scale'
    end

    config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) if ENV['RAILS_LOG_TO_STDOUT'].present?

    config.active_record.whitelist_attributes = false

    config.boot_time = Time.now

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Include developer_portal into the autoload and eager load path
    config.autoload_paths += [Rails.root.join('lib', 'developer_portal', 'app'), Rails.root.join('lib', 'developer_portal', 'lib')]
    config.eager_load_paths += [Rails.root.join('lib', 'developer_portal', 'app'), Rails.root.join('lib', 'developer_portal', 'lib')]

    config.eager_load = true
    config.enable_dependency_loading = false

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

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
      expansions[:defaults] = %w[]
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
      extname.present? && !extname.in?(%w[.map .LICENSE .es6]) && !basename.start_with?('_')
    end
    config.assets.precompile += %w[
      font-awesome.css
      provider/signup_v2.js
      provider/signup_form.js
      provider/layout/provider.js
    ]

    config.assets.compile = false
    config.assets.digest = true
    config.assets.initialize_on_precompile = false

    config.assets.version = '1437647386' # unix timestamp

    config.public_file_server.enabled = false

    # We don't want Rack::Cache to be used
    config.action_dispatch.rack_cache = false

    args = config_for(:cache_store)
    store_type = args.shift
    options = args.extract_options!
    servers = args.flat_map { |arg| arg.split(',') }
    config.cache_store = [store_type, servers, options]

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

    config.three_scale.redhat_customer_portal = ActiveSupport::OrderedOptions.new
    config.three_scale.redhat_customer_portal.enabled = false
    config.three_scale.redhat_customer_portal.merge!(try_config_for(:redhat_customer_portal) || {})

    config.three_scale.payments.enabled = false
    config.three_scale.active_merchant_mode ||= Rails.env.production? ? :production : :test

    config.three_scale.rolling_updates.features = try_config_for(:rolling_updates).deep_merge(try_config_for(:"extra-rolling_updates") || {})

    config.three_scale.service_discovery = ActiveSupport::OrderedOptions.new
    config.three_scale.service_discovery.enabled = false
    config.three_scale.service_discovery.merge!(try_config_for(:service_discovery) || {})

    config.three_scale.plan_rules = ActiveSupport::OrderedOptions.new
    config.three_scale.plan_rules.merge!(try_config_for(:plan_rules) || {})

    config.three_scale.currencies = ActiveSupport::OrderedOptions.new
    config.three_scale.currencies.merge!(try_config_for(:currencies) || {})

    config.three_scale.features = ActiveSupport::OrderedOptions.new
    config.three_scale.features.merge!(try_config_for(:features) || {})

    config.three_scale.message_bus = ActiveSupport::OrderedOptions.new
    config.three_scale.message_bus.merge!(try_config_for(:message_bus) || {})

    config.domain_substitution = ActiveSupport::OrderedOptions.new
    config.domain_substitution.merge!(try_config_for(:domain_substitution) || {})

    config.three_scale.cors = ActiveSupport::OrderedOptions.new
    config.three_scale.cors.enabled = false
    config.three_scale.cors.merge!(try_config_for(:cors) || {})

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
    config.action_mailer.smtp_settings = smtp_config = (try_config_for(:smtp) || {})
    config.action_mailer.raise_delivery_errors = smtp_config[:address].present?

    config.cms_files_path = ':url_root/:date_partition/:basename-:random_secret.:extension'

    require 'three_scale/deprecation'
    require 'three_scale/domain_substitution'
    require 'three_scale/middleware/multitenant'
    require 'three_scale/middleware/cors'

    config.middleware.use ThreeScale::Middleware::Multitenant, :tenant_id
    config.middleware.insert_before Rack::Runtime, Rack::UTF8Sanitizer
    config.middleware.insert_before Rack::Runtime, Rack::XServedBy # we can pass hashed hostname as parameter
    config.middleware.insert_before 0, ThreeScale::Middleware::Cors

    config.unicorn = ActiveSupport::OrderedOptions[after_fork: []]
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
      s3_protocol: ->(*) { CMS::S3.protocol },
      s3_permissions: 'private',
      s3_region: ->(*) { CMS::S3.region },
      s3_host_name: ->(*) { CMS::S3.hostname },
      url: ':storage_root/:class/:id/:attachment/:style/:basename.:extension',
      path: ':rails_root/public/system/:url'
    }.merge(try_config_for(:paperclip) || {})

    initializer :paperclip_defaults, after: :load_config_initializers do
      Paperclip::Attachment.default_options.merge!(s3_options: CMS::S3.options) # Paperclip does not accept s3_options set as a Proc
    end

    config.before_initialize do
      require 'three_scale'
    end

    config.after_initialize do
      ThreeScale.validate_settings!
      require 'system/redis_pool'
      redis_config = ThreeScale::RedisConfig.new(config.redis)
      System.redis = System::RedisPool.new(redis_config.config)

      # Prevents concurrent threads (e.g. sidekiq, puma) to deadlock while racing to obtain access to the mutex block at https://github.com/pat/thinking-sphinx/blob/v3.4.2/lib/thinking_sphinx/configuration.rb#L78
      # This is a ThinkingSphinx's known bug, fixed in v4.3.0+ - see: https://github.com/pat/thinking-sphinx/commit/814beb0aa3d9dd1227c0f41d630888a738f7c0d6
      # See also https://github.com/pat/thinking-sphinx/issues/1051 and https://github.com/pat/thinking-sphinx/issues/1132
      ThinkingSphinx::Configuration.instance.preload_indices if ActiveRecord::Base.connected?
    end

    config.assets.quiet = true

    console do
      if sandbox?
        puts <<~WARNING.strip_heredoc
          \e[5;37;41m
          YOU ARE USING SANDBOX MODE. DO NOT MODIFY RECORDS! THIS IS DANGEROUS AS IT WILL LOCK TABLES!
          See https://github.com/3scale/system/issues/6616
          \e[0m
        WARNING
      end
    end

    # Fixes 'DEPRECATION WARNING: Time columns will become time zone aware in Rails 5.1' keeping backwards compatibility
    config.active_record.time_zone_aware_types = [:datetime]
  end
end

# FIXME: we should cleanup our state machines and remove this
StateMachines::Machine.ignore_method_conflicts = true
