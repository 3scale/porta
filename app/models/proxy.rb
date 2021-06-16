# frozen_string_literal: true

require 'ipaddr'
require 'resolv'

class Proxy < ApplicationRecord
  include AfterCommitQueue
  include BackendApiLogic::ProxyExtension
  prepend BackendApiLogic::RoutingPolicy
  include GatewaySettings::ProxyExtension
  include ProxyConfigAffectingChanges::ModelExtension

  define_proxy_config_affecting_attributes except: %i[api_test_path api_test_success lock_version]

  self.background_deletion = [:proxy_rules, [:proxy_configs, { action: :delete }], [:oidc_configuration, { action: :delete, has_many: false }]]

  DEFAULT_POLICY = { 'name' => 'apicast', 'humanName' => 'APIcast policy', 'description' => 'Main functionality of APIcast.',
                     'configuration' => {}, 'version' => 'builtin', 'enabled' => true, 'removable' => false, 'id' => 'apicast-policy'  }.freeze

  belongs_to :service, touch: true, inverse_of: :proxy, required: true
  attr_readonly :service_id

  has_many :proxy_rules, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :proxy
  has_many :proxy_configs, dependent: :delete_all, inverse_of: :proxy
  has_one :oidc_configuration, dependent: :delete, inverse_of: :oidc_configurable, as: :oidc_configurable
  accepts_nested_attributes_for :oidc_configuration

  has_one :proxy_config_affecting_change, dependent: :delete
  private :proxy_config_affecting_change
  after_commit :create_proxy_config_affecting_change, on: :create

  validates :error_status_no_match, :error_status_auth_missing, :error_status_auth_failed, :error_status_limits_exceeded, presence: true

  uri_pattern = URI::DEFAULT_PARSER.pattern

  URI_OR_LOCALHOST  = /\A(https?:\/\/([a-zA-Z0-9._:\/?-])+|.*localhost.*)\Z/
  OPTIONAL_QUERY_FORMAT = "(?:\\?(#{uri_pattern.fetch(:QUERY)}))?"
  URI_PATH_PART = Regexp.new('\A' + uri_pattern.fetch(:ABS_PATH) + OPTIONAL_QUERY_FORMAT + '\z')
  HOST = Regexp.new('\A' + uri_pattern.fetch(:HOSTNAME) + '(:\d+)?' + '\z')

  OAUTH_PARAMS = /(\?|&)(scope=|state=|tok=)/

  APP_OR_USER_KEY = /\A[\w\d_-]+\Z/

  HTTP_HEADER =  /\A[{}\[\]\d,.;@#~%&()?\w_"= \/\\:-]+\Z/

  OIDC_ISSUER_TYPES = {
    keycloak: I18n.t(:keycloak, scope: 'proxy.oidc_issuer_type').freeze,
    rest: I18n.t(:rest, scope: 'proxy.oidc_issuer_type').freeze,
  }.freeze

  reset_column_information

  validates :api_test_path,    format: { with: URI_PATH_PART,      allow_nil: true, allow_blank: true }

  validates :endpoint,         uri: true, allow_nil: true, allow_blank: true
  validates :sandbox_endpoint, uri: true, allow_nil: true, allow_blank: true

  validates :hostname_rewrite, format: { with: HOST, allow_nil: true, allow_blank: true }

  validates :oauth_login_url, format: { with: URI_OR_LOCALHOST,    allow_nil: true, allow_blank: true }

  validates :oauth_login_url, format: { without: OAUTH_PARAMS }, length: { maximum: 255 }

  validates :credentials_location, inclusion: { in: %w[headers query authorization], allow_nil: false }

  validates :error_status_no_match, :error_status_auth_missing, :error_status_auth_failed, :error_status_limits_exceeded,
                            numericality: { greater_than_or_equal_to: 200, less_than: 600 }

  validates :auth_app_id, :auth_app_key, :auth_user_key, :secret_token,
                      format: { with: APP_OR_USER_KEY, allow_nil: false }

  validates :error_headers_auth_failed,
                      :error_headers_auth_missing, :error_headers_no_match,
                      :error_auth_failed, :error_auth_missing, :error_no_match,
                      :error_headers_limits_exceeded, :error_limits_exceeded,
                      format: { with: HTTP_HEADER }

  validates :api_test_path, length: { maximum: 8192 }
  validates :endpoint, :auth_app_key, :auth_app_id, :auth_user_key,
            :oidc_issuer_endpoint, :oidc_issuer_type,
            :credentials_location, :error_auth_failed, :error_auth_missing, :authentication_method,
            :error_headers_auth_failed, :error_headers_auth_missing, :error_headers_limits_exceeded, :error_limits_exceeded,
            :error_no_match, :error_headers_no_match, :secret_token, :hostname_rewrite, :sandbox_endpoint,
            :staging_domain, :production_domain,
            length: { maximum: 255 }

  validates :oidc_issuer_type, inclusion: { in: OIDC_ISSUER_TYPES.keys.map(&:to_s), allow_blank: true }, presence: { if: ->(proxy) { proxy.oidc_issuer_endpoint.present? } }
  validate :policies_config_structure

  accepts_nested_attributes_for :proxy_rules, allow_destroy: true

  before_validation :set_api_test_path, :create_default_secret_token,  :set_port_sandbox_endpoint, :set_port_endpoint
  after_create :create_default_proxy_rule

  before_create :force_apicast_version
  before_validation :set_sandbox_endpoint, on: :create
  before_validation :set_production_endpoint, on: :create

  validates :sandbox_endpoint, presence: true, on: :update, if: :require_staging_endpoint?
  validates :endpoint, presence: true, on: :update, if: :require_production_endpoint?

  before_save :set_correct_endpoints, if: :set_correct_endpoints?
  before_save :update_domains
  after_save :publish_events
  before_destroy :publish_events

  after_save :track_apicast_version_change, if: :apicast_configuration_driven_changed?

  alias_attribute :production_endpoint, :endpoint
  alias_attribute :staging_endpoint, :sandbox_endpoint

  delegate :account, to: :service
  delegate :provider_can_use?, to: :account
  delegate :backend_apis, :backend_api_configs, to: :service
  delegate :scheduled_for_deletion?, to: :account, allow_nil: true

  def self.user_attribute_names
    super + %w[api_backend] + GatewayConfiguration::ATTRIBUTES
  end

  # This smells of :reek:NilCheck
  def authentication_method
    super.presence || service&.read_attribute(:backend_version)
  end

  def deployment_option
    # Preparation for migrating the column from Service to Proxy
    attribute = __method__
    deployment_option = service&.read_attribute(attribute) || self[attribute]
    deployment_option&.inquiry
  end

  def policies_config
    parsed_config = read_and_parse_policies_config
    return parsed_config if errors[:policies_config].present?

    if parsed_config.detect { |c| c['name'] == DEFAULT_POLICY['name'] }
      parsed_config
    else
      parsed_config.push(DEFAULT_POLICY)
    end
  end

  def policies_config=(attr_policies_config)
    super(attr_policies_config.is_a?(String) ? attr_policies_config : attr_policies_config.to_json)
  end

  def find_policy_config_by(name:, version:)
    policies_config.find { |config| config['name'] == name && config['version'] == version }
  end

  def policy_chain
    # TODO: We need to remove this rolling update as it should be available for everyone using APIcast V2
    return [] unless provider_can_use?(:policies)
    (policies_config.presence || []).each_with_object([]) do |config, chain|
      chain << config.slice('name', 'version', 'configuration') if config['enabled']
    end
  end

  delegate :self_managed?, :hosted?, to: :deployment_option
  delegate :service_token, to: :service, allow_nil: true

  def plugin?
    !hosted? && !self_managed?
  end


  def oidc_configuration
    super || build_oidc_configuration(standard_flow_enabled: true)
  end

  def self.oidc_issuer_types
    OIDC_ISSUER_TYPES.invert
  end

  class DeploymentStrategy
    # @return Proxy
    attr_reader :proxy

    # @return Service
    delegate :service, to: :proxy

    # @param [Proxy] proxy
    def initialize(proxy)
      @proxy = proxy
    end

    def attributes
      {
        staging_endpoint: default_staging_endpoint,
        production_endpoint: default_production_endpoint
      }
    end

    def default_staging_endpoint; end

    def default_production_endpoint; end

    def default_staging_endpoint_apiap; end

    def default_production_endpoint_apiap; end

    protected

    delegate :provider, to: :service
    delegate :subdomain, to: :provider, prefix: true, allow_nil: true

    def config
      proxy.class.config
    end

    def generate(name)
      template = config.fetch(name.try(:to_sym)) { return }

      uri = format template, {
        system_name: service.parameterized_system_name, account_id: service.account_id,
        tenant_name: provider_subdomain,
        env: proxy.proxy_env, port: proxy.proxy_port
      }

      UriShortener.call(uri).to_s
    end
  end

  class SelfManagedAPIcast < DeploymentStrategy
    def default_staging_endpoint
      staging_endpoint = proxy.apicast_configuration_driven ? nil : :sandbox_endpoint
      generate(staging_endpoint)
    end
  end

  class HostedAPIcast < DeploymentStrategy
    def default_staging_endpoint
      staging_endpoint = proxy.apicast_configuration_driven ? :apicast_staging_endpoint : :sandbox_endpoint
      generate(staging_endpoint)
    end

    def default_production_endpoint
      production_endpoint = proxy.apicast_configuration_driven ? :apicast_production_endpoint : :hosted_proxy_endpoint
      generate(production_endpoint)
    end

    def default_staging_endpoint_apiap
      default_staging_endpoint
    end

    def default_production_endpoint_apiap
      default_production_endpoint
    end
  end

  # @return DeploymentStrategy
  def deployment_strategy
    strategy = case deployment_option
               when 'self_managed' then SelfManagedAPIcast
               when 'hosted' then HostedAPIcast
               end

    strategy.try!(:new, self)
  end

  def deployment_strategy_apiap
    HostedAPIcast.new self
  end

  def oidc?
    provider&.provider_can_use?(:apicast_oidc) && authentication_method.to_s == 'oidc'
  end

  # beware that in the on-prem product deployment option is 'hosted'
  def saas_script_driven_apicast_self_managed?
    !apicast_configuration_driven && self_managed?
  end

  # beware that in the on-prem product deployment option is 'hosted'
  def saas_configuration_driven_apicast_self_managed?
    apicast_configuration_driven && self_managed?
  end

  def require_staging_endpoint?
    !(saas_configuration_driven_apicast_self_managed? || plugin?)
  end

  def require_production_endpoint?
    hosted?
  end

  def self.credentials_collection
    I18n.t('proxy.credentials_location').to_a.map(&:reverse)
  end

  def set_correct_endpoints?
    apicast_configuration_driven_changed? || new_record?
  end

  def publish_events
    OIDC::ProxyChangedEvent.create_and_publish!(self)
    Domains::ProxyDomainsChangedEvent.create_and_publish!(self)
    nil
  end

  DEPLOYMENT_OPTION_CHANGED = ->(record) { record.changed_attributes.key?(:deployment_option) }

  def deployment_option_changed?
    [ self, service ].any?(&DEPLOYMENT_OPTION_CHANGED)
  end

  # We want to autosave when Service#deployment_option changed
  def changed_for_autosave?
    deployment_option_changed? or super
  end

  def self.config
    System::Application.config.three_scale.sandbox_proxy
  end

  def track_apicast_version_change
    tracking = ThreeScale::Analytics.current_user

    run_after_commit do
      tracking.track('APIcast Hosted Version Change',
                     enabled: apicast_configuration_driven?,
                     service_id: service_id,
                     deployment_option: deployment_option
      )
    end
  end

  def hosts
    [endpoint, sandbox_endpoint].map do |endpoint|
      begin
        URI(endpoint || '').host
      rescue ArgumentError, URI::InvalidURIError
        'localhost'
      end
    end.compact.uniq
  end

  def backend
    config = self.class.config
    old_endpoint_config = "#{config.backend_scheme}://#{config.backend_host}"
    endpoint = URI(config.backend_endpoint.presence || old_endpoint_config)

    {
      endpoint: endpoint.to_s,
      host: endpoint.host
    }
  end

  def save_and_deploy(attrs = {})
    saved = update_attributes(attrs)

    analytics.track('Sandbox Proxy updated', analytics_attributes.merge(success: saved))

    return false unless saved

    success = ProxyDeploymentService.call(self, v1_compatible: true)
    analytics.track('Sandbox Proxy Deploy', success: success)
    success
  end

  def authentication_params_for_proxy(opts = {})
    params = service.plugin_authentication_params
    keys_to_proxy_args = {app_key: :auth_app_key,
                          app_id: :auth_app_id,
                          user_key: :auth_user_key,  }

    # {'app_id' => 'foo', 'app_key_mine' => 'bar'}
    params.keys.map do |x|
       param_name = opts[:original_names] ? x.to_s : send(keys_to_proxy_args[x])
       [ param_name, params[x]  ]
    end.to_h
  end

  def authorization_credentials
    params = authentication_params_for_proxy.symbolize_keys
    params.values_at(:user_key).compact.presence || params.values_at(:app_id, :app_key)
  end

  def skip_test_request?
    service.oauth? || saas_configuration_driven_apicast_self_managed?
  end

  def enabled
    !!self.deployed_at
  end

  def sandbox_deployed?
    proxy_log = provider.proxy_logs.latest_first.first or return sandbox_config_saved?
    proxy_log.created_at > self.created_at && proxy_log.status == ApicastV1DeploymentService::SUCCESS_MESSAGE
  end

  def sandbox_config_saved?
    proxy_configs.sandbox.exists?
  end

  def endpoint_port
    URI(endpoint.presence).port
  rescue ArgumentError, URI::InvalidURIError
    URI::HTTP::DEFAULT_PORT
  end

  def hostname_rewrite_for_sandbox
    hostname_rewrite.presence ||
      (self.api_backend ? URI(self.api_backend).host : 'none')
  end

  def ready_to_deploy?
    api_test_success
  end

  def set_correct_endpoints
    endpoints = deployment_strategy.try(:attributes).presence

    assign_attributes(endpoints) if endpoints
  end

  def apicast_configuration_driven
    if provider && provider.provider_can_use?(:apicast_v2) && !provider.provider_can_use?(:apicast_v1)
      true
    else
      super
    end
  end

  def force_apicast_version
    self.apicast_configuration_driven = apicast_configuration_driven
    true # this can be removed when we swith to thow callbacks
  end

  delegate :default_production_endpoint, :default_staging_endpoint,
           to: :deployment_strategy, allow_nil: true

  delegate :default_production_endpoint_apiap, :default_staging_endpoint_apiap,
           to: :deployment_strategy_apiap, allow_nil: true

  delegate :backend_version, to: :service, prefix: true



  delegate :provider_key, to: :provider


  def sandbox_host
    URI(sandbox_endpoint || set_sandbox_endpoint).host
  end

  def update_domains
    domains = {
      staging_domain: self.class.extract_domain(sandbox_endpoint.presence || default_staging_endpoint),
      production_domain: self.class.extract_domain(endpoint.presence || default_production_endpoint),
    }
    assign_attributes(domains)
    domains
  end

  def provider
    @provider ||= self.service&.account
  end

  PROXY_ENV = {
    preview: 'pre.',
    production: ''
  }.freeze

  def proxy_env
    PROXY_ENV.fetch(Rails.env.to_sym, '')
  end

  def proxy_port
    self.class.config.fetch(:port) { Rails.env.test? ? '44432' : '443' }
  end

  def deployable?
    Service::DeploymentOption.gateways.include?(deployment_option) || service_mesh_integration?
  end

  def service_mesh_integration?
    Service::DeploymentOption.service_mesh.include?(deployment_option)
  end

  # Ridiculously hacking Rails to skip lock increment on touch
  def touch(*)
    @instance_locking_enabled = false
    super
  ensure
    remove_instance_variable(:@instance_locking_enabled)
  end

  def locking_enabled?
    return @instance_locking_enabled if instance_variable_defined? :@instance_locking_enabled
    super
  end

  def affecting_change_history
    proxy_config_affecting_change || create_proxy_config_affecting_change
  end

  def pending_affecting_changes?
    return unless apicast_configuration_driven?
    config = proxy_configs.sandbox.newest_first.first
    return false unless config
    config.created_at < affecting_change_history.updated_at
  end

  def proxy
    self
  end

  protected

  class PolicyConfig
    include ActiveModel::Validations

    attr_accessor :name, :version, :configuration, :enabled

    validates :name, :version, presence: true
    validate :configuration_is_object

    def initialize(attributes = {})
      self.attributes = attributes.is_a?(Hash) ? attributes : {}
    end

    def attributes=(attributes)
      symbolized_attributes = attributes.symbolize_keys
      @name = symbolized_attributes[:name]
      @version = symbolized_attributes[:version]
      @configuration = symbolized_attributes[:configuration]
      @enabled = symbolized_attributes[:enabled]
    end

    private

    def configuration_is_object
      errors.add(:configuration, :blank) if configuration != {} && configuration.blank?
    end
  end

  class PoliciesConfig
    include ActiveModel::Validations

    delegate :each, to: :policies_config
    attr_reader :policies_config

    validate :policies_configs_are_correct

    def initialize(policies_config)
      @policies_config = policies_config.map { |attrs| PolicyConfig.new(attrs) }
    end

    def self.name
      'PoliciesConfig'
    end

    private

    def policies_configs_are_correct
      policies_config.each do |policy_config|
        # TODO: 5: errors.merge!(policy_config.errors)
        policy_config.errors.each { |attribute, message| errors.add(attribute, message) } unless policy_config.valid?
      end
    end
  end

  def read_and_parse_policies_config
    read_and_parse_policies_config!
  rescue JSON::ParserError
    []
  end

  def read_and_parse_policies_config!
    attr_policies_config = read_attribute(:policies_config)
    attr_policies_config.blank? ? [] : Array(JSON.parse(attr_policies_config))
  end

  def policies_config_structure
    parsed_config = read_and_parse_policies_config!
    policies_object = PoliciesConfig.new(parsed_config)
    return if policies_object.valid?
    policies_object.errors.each do |attribute, message|
      errors.add(:policies_config, errors.full_message(attribute, message).downcase)
    end
  rescue JSON::ParserError
    errors.add(:policies_config, :invalid_format)
  end

  def create_default_secret_token
    unless secret_token
      self.secret_token = "Shared_secret_sent_from_proxy_to_API_backend_#{SecureRandom.hex(8)}"
    end
  end

  def analytics
    ThreeScale::Analytics.current_user
  end

  def analytics_attributes
    { api_backend: api_backend, api_test_path: api_test_path }
  end

  def create_default_proxy_rule
    if (hits = service.metrics.first)
      proxy_rules.create(http_method: 'GET', pattern: '/', delta: 1, metric: hits)
    end
  end

  def create_proxy_config_affecting_change(*)
    return unless persisted?
    super
  rescue ActiveRecord::RecordNotUnique
    reload.send(:proxy_config_affecting_change)
  end

  def set_api_test_path
    self.api_test_path ||= '/'
  end

  def set_sandbox_endpoint
    url = default_staging_endpoint
    return if url.blank?
    self.sandbox_endpoint = url
  end

  def set_production_endpoint
    url = default_production_endpoint
    return if url.blank?
    self.endpoint = url
  end

  def set_port_sandbox_endpoint
    generate_port(:sandbox_endpoint)
  end

  def set_port_endpoint
    generate_port(:endpoint)
  end

  def self.extract_domain(url)
    URI(url.presence || '').host
  rescue ArgumentError, URI::InvalidURIError
    # nothing
  end

  class PortGenerator
    def initialize(model)
      @model = model
    end

    def call(attribute)
      attribute_value = @model[attribute]
      return if attribute_value.blank?

      begin
        uri = URI.parse(attribute_value)
        value = URI::Generic.new(uri.scheme, uri.userinfo, uri.host, uri.port, uri.registry, uri.path, uri.opaque, uri.query, uri.fragment).to_s
        @model[attribute] = value
      rescue URI::InvalidURIError
        @model.errors.add(attribute, 'Invalid domain')
      end
    end
  end

  def generate_port(proxy_attribute)
    PortGenerator.new(self).call(proxy_attribute)
  end
end
