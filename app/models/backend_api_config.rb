# frozen_string_literal: true

class BackendApiConfig < ApplicationRecord
  include Backend::ModelExtensions::BackendApiConfig
  include ProxyConfigAffectingChanges::ModelExtension

  default_scope -> { order(id: :asc) }
  belongs_to :service, inverse_of: :backend_api_configs
  belongs_to :backend_api, inverse_of: :backend_api_configs

  include ThreeScale::Search::Scopes

  self.allowed_sort_columns = %w[backend_apis.name backend_apis.private_endpoint backend_api_config.path]
  self.default_sort_column = 'backend_apis.name'
  self.default_sort_direction = :asc

  has_many :backend_api_metrics, through: :backend_api, source: :metrics

  has_many :usage_limits, ->(backend_usage) { of_metric(Metric.unscoped.where(owner_type: "BackendApi", owner_id: backend_usage.backend_api_id)) }, through: :service

  validates :service_id, :backend_api_id, presence: true
  validates :backend_api_id, uniqueness: { scope: :service_id, case_sensitive: true }
  validates :path, uniqueness: { scope: :service_id, case_sensitive: false, message: "This path is already taken. Specify a different path." }
  validates :path, length: { in: 1..255, allow_nil: false }, path: true

  before_destroy :destroy_usage_limits

  scope :by_service,     ->(service_id)     { where.has { self.service_id     == service_id     } }
  scope :by_backend_api, ->(backend_api_id) { where.has { self.backend_api_id == backend_api_id } }

  scope :with_subpath, -> { where.not(path: ConfigPath::EMPTY_PATH) }

  scope :accessible, -> do
    joining { service }.where.has { (service.state != ::Service::DELETE_STATE) }
  end

  scope :sorted_for_proxy_config, -> { reordering { sift(:desc, :path) } }

  delegate :private_endpoint, to: :backend_api

  delegate :proxy, to: :service, allow_nil: true

  def with_subpath?
    path != ConfigPath::EMPTY_PATH
  end

  def path=(value)
    super(ConfigPath.new(value).path)
  end

  private

  def destroy_usage_limits
    usage_limits.find_each(&:destroy!)
  end
end
