# frozen_string_literal: true

class ProxyConfig < ApplicationRecord
  class InvalidEnvironmentError < StandardError; end
  ENVIRONMENTS = %w[sandbox production].freeze

  ENVIRONMENT_CHECK = ->(env) do
    ENVIRONMENTS.include?(env) ? env : raise(InvalidEnvironmentError, env)
  end

  VALID_ENVIRONMENTS = Hash.new { |_,env| ENVIRONMENT_CHECK.call(env) }
                           .merge('staging' => 'sandbox').freeze

  # Do not set it too high though the column accept until 16.megabytes
  MAX_CONTENT_LENGTH = 2.megabytes

  belongs_to :proxy, optional: false
  belongs_to :user, optional: true

  attr_readonly :proxy_id, :user_id, :version, :environment, :content
  delegate :service_token, :api_backend, to: :proxy, allow_nil: true

  validates :version,
            uniqueness: { scope: [ :proxy_id, :environment ] },
            numericality: { only_integer: true }
  validates :content, :version, :environment, presence: true
  validates :environment, inclusion: { in: ENVIRONMENTS }
  validate :service_token_exists
  validate :api_backend_exists, on: :create, unless: :service_mesh_integration?
  validates :content, length: { maximum: MAX_CONTENT_LENGTH }

  before_create :denormalize_hosts
  after_create :update_version

  scope :sandbox,        -> { where(environment: 'sandbox') }
  scope :production,     -> { where(environment: 'production') }
  scope :newest_first,   -> { order(version: :desc) }
  scope :by_environment, ->(env) { where(environment: VALID_ENVIRONMENTS[env]) }
  scope :by_host,        ->(host) { where.has { hosts =~ "%|#{host}|%" } if host }

  scope :current_versions, -> do
    where('NOT EXISTS (SELECT 1 FROM proxy_configs pc where proxy_configs.environment = environment AND proxy_configs.proxy_id = proxy_id AND proxy_configs.version < version)')
  end

  scope :by_version, ->(version) do
    next unless version
    next current_versions if version == 'latest'

    where(version: version)
  end

  def differs_from?(comparable)
    return true if comparable.blank?

    content != comparable.content
  end

  def relation_scope
    self.class.where(proxy_id: proxy_id, environment: environment)
  end

  def content_type
    Mime['json']
  end

  def filename
    "apicast-config-#{proxy.service.parameterized_name}-#{environment}-#{version}.json"
  end

  def sandbox_endpoint
    parsed_content.dig(:proxy, :sandbox_endpoint)
  end

  def sandbox_host
    extract_host(sandbox_endpoint)
  end

  def production_endpoint
    parsed_content.dig(:proxy, :endpoint)
  end

  def production_host
    extract_host(production_endpoint)
  end

  def hosts
    super.to_s.split('|').reject(&:empty?)
  end

  def update_version
    return if version.try(:positive?)

    config = self.class.unscoped.where(self.class.primary_key => id)
    # This is a way how to atomically increment a column scoped by some other column.
    # Double subquery because mysql needs to create a temporary table.
    # You can't run an UPDATE and subquery from the same table without any temporary one.

    config.update_all("version = 1 + (#{Arel.sql max_version.to_sql})")

    # Read the value
    version = config.connection.select_value(config.select(:version)).to_i
    raw_write_attribute :version, version
  end

  def clone_to(environment:)
    EnvironmentClone.new(self, environment).call
  end

  def service_token_exists
    return if service_token

    errors.add :service_token, :missing
  end

  def parsed_content
    JSON.parse(content).deep_symbolize_keys
  end

  private

  delegate :service_mesh_integration?, to: :proxy, allow_nil: true

  def api_backend_exists
    # FIXME: we should remove the nil check
    return if proxy&.api_backend_present?

    errors.add :api_backend, :missing
  end

  def max_version
    ProxyConfig.select(:version).from(relation_scope.selecting { coalesce(max(version), 0).as('version') })
  end

  def extract_host(endpoint)
    URI(endpoint).host if endpoint
  end

  def denormalize_hosts
    content = parsed_content
    content_hosts = content.dig(:proxy, :hosts) || []

    self.hosts = content_hosts.any? ? "|#{content_hosts.join('|')}|" : nil
  end

  class EnvironmentClone

    def initialize(config_to_clone, destination_env)
      @config_to_clone = config_to_clone
      @destination_env = destination_env
    end

    def call
      config_clone = config_to_clone.dup
      config_clone.environment = destination_env
      config_clone.save
      config_clone
    end

    private

    attr_reader :config_to_clone, :destination_env
  end
end
