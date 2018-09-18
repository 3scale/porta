class ProxyConfig < ApplicationRecord
  class InvalidEnvironmentError < StandardError; end
  ENVIRONMENTS = %w(sandbox production).freeze

  ENVIRONMENT_CHECK = lambda do |env|
    ENVIRONMENTS.include?(env) ? env : raise(InvalidEnvironmentError, env)
  end

  VALID_ENVIRONMENTS = Hash.new { |_,env| ENVIRONMENT_CHECK.call(env) }
                           .merge('staging' => 'sandbox').freeze

  belongs_to :proxy, required: true
  belongs_to :user, required: false

  attr_readonly :proxy_id, :user_id, :version, :environment, :content
  delegate :service_token, to: :proxy, allow_nil: true

  validates :version,
            uniqueness: { scope: [ :proxy_id, :environment ] },
            numericality: { only_integer: true }
  validates :content, :version, :environment, presence: true
  validates :environment, inclusion: { in: ENVIRONMENTS }
  validate :service_token_exists

  after_create :update_version
  before_create :denormalize_hosts

  scope :sandbox,        -> { where(environment: 'sandbox'.freeze) }
  scope :production,     -> { where(environment: 'production'.freeze) }
  scope :newest_first,   -> { order(version: :desc) }
  scope :by_environment, ->(env) { where(environment: VALID_ENVIRONMENTS[env]) }
  scope :by_host,        ->(host) { where.has { hosts =~ "%|#{host}|%" } if host }
  scope :for_services,   ->(services) do
    joins(:proxy).merge(::Proxy.where(service_id: services))
  end
  scope :current_versions, -> do
    table = BabySqueel[:proxy_configs].alias(:versions)
    scope = joining { table.on((table.proxy_id == proxy_id) & (table.environment == environment)) }
      .when_having { max(table.version) == version }
      .group(:id)

    System::Database.oracle? ? where(id: scope.group(:version).select(:id)) : scope
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
    "apicast-config-#{proxy.service.parameterized_name}-#{environment}-#{version}.json".freeze
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
    super.to_s.split('|'.freeze).reject(&:empty?)
  end

  def update_version
    return if version.try(:positive?)

    config = self.class.unscoped.where(self.class.primary_key => id)
    # This is a way how to atomically increment a column scoped by some other column.
    # Double subquery because mysql needs to create a temporary table.
    # You can't run an UPDATE and subquery from the same table without any temporary one.

    config.update_all("#{self.class.table_name}.version = 1 + (#{Arel.sql max_version.to_sql})")

    # Read the value
    version = config.connection.select_value(config.select(:version))
    raw_write_attribute :version, version
  end

  def max_version
    ProxyConfig.select(:version).from(relation_scope.selecting { coalesce(max(version), 0).as('version') })
  end

  def clone_to(environment:)
    EnvironmentClone.new(self, environment).call
  end

  def service_token_exists
    return if service_token
    errors.add :service_token, :missing
  end

  private

  def extract_host(endpoint)
    URI(endpoint).host if endpoint
  end

  def parsed_content
    JSON.parse(content).deep_symbolize_keys
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
