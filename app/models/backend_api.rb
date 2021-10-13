# frozen_string_literal: true

class BackendApi < ApplicationRecord
  include Searchable
  include SystemName
  include ProxyConfigAffectingChanges::ModelExtension

  define_proxy_config_affecting_attributes :private_endpoint

  self.background_deletion = %i[proxy_rules metrics backend_api_configs]

  DELETED_STATE = :deleted
  ECHO_API_HOST = 'echo-api.3scale.net'

  before_validation :set_port_private_endpoint
  after_create :create_default_metrics
  before_destroy :validate_destroyed_by_association_or_not_used_by_services

  has_many :proxy_rules, as: :owner, dependent: :destroy, inverse_of: :owner
  has_many :metrics, as: :owner, dependent: :destroy, inverse_of: :owner
  alias_method :all_metrics, :metrics

  has_many :backend_api_configs, inverse_of: :backend_api, dependent: :destroy
  has_many :services, through: :backend_api_configs
  has_many :proxies, through: :services

  belongs_to :account, inverse_of: :backend_apis

  delegate :provider_can_use?, to: :account, allow_nil: true
  delegate :default_api_backend, to: :class

  validates :name,        length: { maximum: 511 }, presence: true
  validates :state,       length: { maximum: 255 }
  validates :system_name, length: { maximum: 255 }, presence: true

  validates :private_endpoint, length: { maximum: 255 },
    presence: true,
    uri: { path: ->(backend_api_object) { backend_api_object.provider_can_use?(:proxy_private_base_path) }, scheme: %w[http https ws wss] },
    non_localhost: { message: :protected_domain }

  alias_attribute :api_backend, :private_endpoint

  has_system_name(uniqueness_scope: [:account_id])

  scope :orphans, -> {
    where.has do
      not_exists(BackendApiConfig.except(:order).by_backend_api(BabySqueel[:backend_apis].id).select(:id))
    end
  }

  scope :not_used_by, ->(service_id) {
    where.has do
      not_exists(
        BackendApiConfig.except(:order).select(:id)
          .by_service(service_id)
          .by_backend_api(BabySqueel[:backend_apis].id)
      )
    end
  }

  scope :oldest_first, -> { order(created_at: :asc) }
  scope :accessible, -> { where.not(state: DELETED_STATE) }

  state_machine initial: :published do
    state :published
    state DELETED_STATE do
      validate :validate_destroyed_by_association_or_not_used_by_services
    end

    event :mark_as_deleted do
      transition [:published] => DELETED_STATE
    end

    after_transition to: [DELETED_STATE], do: :schedule_deletion
  end

  def self.default_api_backend
    "https://#{ECHO_API_HOST}:443"
  end

  def first_service
    backend_api_configs.first&.service
  end

  alias mapping_rules proxy_rules

  def top_level_metrics
    metrics.top_level
  end

  def method_metrics
    metrics.where(parent: metrics.hits)
  end

  def create_default_metrics
    metrics.create_default!(:hits)
  end

  def scheduled_for_deletion?
    deleted? || !account || account.scheduled_for_deletion?
  end

  private

  def schedule_deletion
    DeleteObjectHierarchyWorker.perform_later(self)
  end

  def set_port_private_endpoint
    Proxy::PortGenerator.new(self).call(:private_endpoint)
  end

  def validate_destroyed_by_association_or_not_used_by_services
    return true if destroyed_by_association || backend_api_configs.empty?
    errors.add(:base, :cannot_be_destroyed_with_products)
    throw :abort
  end
end
