# frozen_string_literal: true

require_relative "boot"

# We don't want to load any Rails component we don't use
# See https://github.com/rails/rails/blob/v7.1.5.1/railties/lib/rails/all.rb for the list
# of what is being included here
require "rails"

# Omitted Rails components
#   active_storage/engine
#   action_cable/engine
#   action_mailbox/engine
#   action_text/engine

%w[
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  rails/test_unit/railtie
  sprockets/railtie
].each do |railtie|
  require railtie
rescue LoadError
end

ActiveSupport.on_load(:active_record) do
  # Some rails tasks like db:create may load database before environment
  if $environment_loaded && !$last_initializer_loaded
    warning = "WARNING: ActiveRecord loading before initializers completed. Configuration set in initializers may not be effective:#{caller.map { |l| "\n  #{l}"}.join}"
    STDERR.puts warning rescue nil # avoid failing if write fails
  end
end

# If you precompile assets before deploying to production, use this line
Bundler.require(*Rails.groups(:oracle, assets: %w[development production test]))
# If you want your assets lazily compiled in production, use this line
# Bundler.require(:default, :assets, Rails.env)

ActiveSupport::XmlMini.backend = 'Nokogiri'

module System

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
    # we do here instead of using initializers because of a Rails 5.1 vs
    # MySQL bug where `rake db:reset` causes ActiveRecord to be loaded
    # before initializers and causes configuration not to be respected.
    config.load_defaults 7.1

    # TODO: consider removing this to enable the default value 'true', and setting `allow_other_host: true` for `redirect_to` only where needed
    # Protect from open redirect attacks in `redirect_back_or_to` and `redirect_to`.
    config.action_controller.raise_on_open_redirects = false

    # Change the format of the cache entry.
    #
    # Changing this default means that all new cache entries added to the cache
    # will have a different format that is not supported by Rails 7.0
    # applications.
    # Only change this value after your application is fully deployed to Rails 7.1
    # and you have no plans to rollback.
    # TODO: update to 7.1
    config.active_support.cache_format_version = 7.0

    # To migrate an existing application to the `:json` serializer, use the `:hybrid` option.
    #
    # Rails transparently deserializes existing (Marshal-serialized) cookies on read and
    # re-writes them in the JSON format.
    #
    # It is fine to use `:hybrid` long term; you should do that until you're confident *all* your cookies
    # have been converted to JSON. To keep using `:hybrid` long term, move this config to its own
    # initializer or to `config/application.rb`.
    # TODO: use the new default - THREESCALE-11545
    config.action_dispatch.cookies_serializer = :hybrid

    config.active_record.belongs_to_required_by_default = false
    config.active_record.include_root_in_json = true

    # Support for inversing belongs_to -> has_many Active Record associations.
    # Overriding the default (since Rails 6.1) default, because it causes various issues.
    # Likely we need to keep it forever as we can't override it for individual use cases.
    # Also the feature has outstanding bugs: rails/rails#47559 rails/rails#50258.
    config.active_record.has_many_inversing = false

    # Make `form_with` generate non-remote forms. Defaults true in Rails 5.1 to 6.0
    config.action_view.form_with_generates_remote_forms = false

    # Disable generating Link header with URLs from javascript_include_tag and stylesheet_link_tag
    # Reconsider whether to enable again after upgrading to Rails 7.1, where the size of the header is limited to 1KB
    config.action_view.preload_links_header = false

    # TODO: remove this config to get rid of the deprecation before upgrading to Rails 7.2
    # DEPRECATION WARNING: Support for the pre-Ruby 2.4 behavior of to_time has been deprecated and will be removed in Rails 7.2.
    # Make Ruby preserve the timezone of the receiver when calling `to_time`.
    config.active_support.to_time_preserves_timezone = false

    # Applying the patch for CVE-2022-32224 broke YAML deserialization because some classes are disallowed in the serialized YAML
    config.active_record.yaml_column_permitted_classes = [Symbol, Time, Date, BigDecimal, OpenStruct,
                                                          ActionController::Parameters,
                                                          ActiveSupport::TimeWithZone,
                                                          ActiveSupport::TimeZone,
                                                          ActiveSupport::HashWithIndifferentAccess,
                                                          'HashWithIndifferentAccess']

    # Keeping the historic behavior by setting to `YAML`
    # It is recommended to explicitly define the serialization method for each column
    # rather than to rely on a global default.
    # TODO: see if we can use the Rails 7.1 default `nil` value by setting serialization for each column explicitly
    config.active_record.default_column_serializer = YAML

    # The default behavior in 7.1 is to raise on assignment to attr_readonly attributes.
    # This setting restores the previous behavior which allows assignment but silently not persist changes to the
    # database.
    config.active_record.raise_on_assign_to_attr_readonly = false

    # By default (from Rails 7.1), transaction callbacks will run in the order they are defined.
    # Prior to 7.1 the order in which the callbacks were run was reversed.
    # This change caused a bug in sending the usage limits to backend (see THREESCALE-11945)
    # Setting this config to quickly fix the issue, and avoid having to review all callbacks throughout the code base
    config.active_record.run_after_transaction_callbacks_in_order_defined = false

    config.active_job.queue_adapter = :sidekiq

    def try_config_for(*args)
      config_for(*args)
    rescue => exception # rubocop:disable Style/RescueStandardError
      warn "[Warning][ConfigFor] Failed to load config with: #{exception}" if $VERBOSE
      nil
    end

    config.before_eager_load do
      require 'three_scale'
    end

    config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) if ENV['RAILS_LOG_TO_STDOUT'].present?

    config.active_record.whitelist_attributes = false

    config.boot_time = Time.now

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Include developer_portal into the autoload and eager load path
    config.autoload_paths += [Rails.root.join('lib', 'developer_portal', 'app'), Rails.root.join('lib', 'developer_portal', 'lib')]
    config.eager_load_paths += [Rails.root.join('lib', 'developer_portal', 'app'), Rails.root.join('lib', 'developer_portal', 'lib')]

    config.eager_load = true

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

    config.assets.enabled = true
    config.assets.quiet = true

    config.public_file_server.enabled = false

    # We don't want Rack::Cache to be used
    config.action_dispatch.rack_cache = false

    def cache_store_config
      args = config_for(:cache_store)
      store_type = args.shift
      options = args.extract_options!
      options[:digest_class] ||= Digest::SHA256 if store_type == :mem_cache_store
      [store_type, *args, options]
    end
    config.cache_store = cache_store_config

      # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.web_hooks = ActiveSupport::OrderedOptions.new
    config.web_hooks.merge!(config_for(:web_hooks))

    config.liquid = ActiveSupport::OrderedOptions.new
    config.liquid.resolver_caching = false

    config.representer.default_url_options = { protocol: 'https' }

    config.zync = ActiveSupport::InheritableOptions.new(try_config_for(:zync))

    config.three_scale = ActiveSupport::OrderedOptions.new
    config.three_scale.core = ActiveSupport::OrderedOptions.new

    config.three_scale.rolling_updates = ActiveSupport::OrderedOptions.new
    config.three_scale.email_sanitizer = ActiveSupport::OrderedOptions.new
    config.three_scale.sandbox_proxy = ActiveSupport::OrderedOptions.new
    config.three_scale.sandbox_proxy.merge!(config_for(:sandbox_proxy))

    config.three_scale.tracking = ActiveSupport::OrderedOptions.new
    config.three_scale.core.merge!(config_for(:core))

    config.three_scale.segment = ActiveSupport::OrderedOptions.new
    config.three_scale.segment.merge!(config_for(:segment))

    config.three_scale.redhat_customer_portal = ActiveSupport::OrderedOptions.new
    config.three_scale.redhat_customer_portal.enabled = false
    config.three_scale.redhat_customer_portal.merge!(try_config_for(:redhat_customer_portal) || {})

    config.three_scale.rolling_updates.features = try_config_for(:rolling_updates)&.deep_merge(try_config_for(:"extra-rolling_updates") || {})

    config.three_scale.service_discovery = ActiveSupport::OrderedOptions.new
    config.three_scale.service_discovery.enabled = false
    config.three_scale.service_discovery.merge!(try_config_for(:service_discovery) || {})

    config.three_scale.plan_rules = ActiveSupport::OrderedOptions.new
    config.three_scale.plan_rules.merge!(try_config_for(:plan_rules) || {})

    config.three_scale.currencies = ActiveSupport::OrderedOptions.new
    config.three_scale.currencies.merge!(try_config_for(:currencies) || {})

    config.three_scale.features = ActiveSupport::OrderedOptions.new
    config.three_scale.features.merge!(try_config_for(:features) || {})

    config.domain_substitution = ActiveSupport::OrderedOptions.new
    config.domain_substitution.merge!(try_config_for(:domain_substitution) || {})

    config.three_scale.cors = ActiveSupport::OrderedOptions.new
    config.three_scale.cors.enabled = false
    config.three_scale.cors.merge!(try_config_for(:cors) || {})

    three_scale = config_for(:settings)

    three_scale[:error_reporting_stages] = three_scale[:error_reporting_stages].to_s.split(/\W+/)

    payment_settings = three_scale.extract!(:active_merchant_mode, :active_merchant_logging, :billing_canaries)
    config.three_scale.payments = ActiveSupport::OrderedOptions.new
    config.three_scale.payments.enabled = false
    config.three_scale.payments.merge!(payment_settings)
    config.three_scale.payments.merge!(try_config_for(:payments) || {})
    config.three_scale.payments.active_merchant_mode ||= Rails.env.production? ? :production : :test

    email_sanitizer_configs = (three_scale.delete(:email_sanitizer) || {})
    config.three_scale.email_sanitizer.merge!(email_sanitizer_configs)

    config.three_scale.merge!(three_scale.slice!(:force_ssl))
    three_scale.each do |key, val|
      config.public_send("#{key}=", val)
    end

    config.action_mailer.default_url_options = { protocol: 'https' }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = smtp_config = (try_config_for(:smtp) || {})
    config.action_mailer.raise_delivery_errors = smtp_config[:address].present?

    config.cms_files_path = ':url_root/:date_partition/:basename-:random_secret.:extension'

    # Add a custom deprecator, silenced in test and production
    Rails.application.deprecators[:threescale] = ActiveSupport::Deprecation.new('future version', '3scale')
    Rails.application.deprecators[:threescale].silenced = %w[test production].include?(Rails.env)

    require "three_scale"

    config.middleware.use ThreeScale::Middleware::Multitenant, :tenant_id unless ENV["DEBUG_DISABLE_TENANT_CHECK"] == "1"
    config.middleware.insert_before ActionDispatch::Static, ThreeScale::Middleware::PresignedDownloads
    config.middleware.insert_before Rack::Runtime, Rack::UTF8Sanitizer
    config.middleware.insert_before(Rack::Runtime, Rack::XServedBy) if ENV["DEBUG_X_SERVED_BY"] == "1"
    config.middleware.insert_before 0, ThreeScale::Middleware::Cors if config.three_scale.cors.enabled

    config.unicorn = ActiveSupport::OrderedOptions[after_fork: []]

    config.action_dispatch.cookies_serializer = :hybrid

    initializer :load_configs, before: :load_config_initializers do
      config.backend_client = { max_tries: 5 }.merge(config_for(:backend))
      config.redis = config_for(:redis)
      config.s3 = config_for(:amazon_s3)
      config.three_scale.oauth2 = config_for(:oauth2)
    end

    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: ->(*) { CMS::S3.credentials },
      bucket: ->(*) { CMS::S3.bucket },
      s3_protocol: ->(*) { CMS::S3.protocol },
      s3_permissions: 'private',
      s3_headers: { "checksum-algorithm" => "SHA256" },
      s3_region: ->(*) { CMS::S3.region },
      s3_host_name: ->(*) { CMS::S3.hostname },
      url: ':storage_root/:class/:id/:attachment/:style/:basename.:extension',
      path: ':rails_root/public/system/:url'
    }.merge(try_config_for(:paperclip) || {})

    config.to_prepare do
      Rails.application.config.log_formatter = System::ErrorReporting::LogFormatter.new
      (Rails.application.config.logger || Rails.logger).formatter = Rails.application.config.log_formatter

      Paperclip::Attachment.default_options[:s3_options] = CMS::S3.options # Paperclip does not accept s3_options set as a Proc
    end

    config.after_initialize do
      ThreeScale.validate_settings!
      System.redis = System::RedisPool.new(System::Application.config.redis)
    end

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
