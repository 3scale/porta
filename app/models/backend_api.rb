# frozen_string_literal: true

class BackendApi < ApplicationRecord
  include SystemName

  DELETED_STATE = :deleted
  ECHO_API_HOST = 'echo-api.3scale.net'

  has_many :proxy_rules, as: :owner, dependent: :destroy, inverse_of: :owner
  has_many :metrics, as: :owner, dependent: :destroy, inverse_of: :owner

  has_many :backend_api_configs, inverse_of: :backend_api, dependent: :destroy
  has_many :services, through: :backend_api_configs
  belongs_to :account, inverse_of: :backend_apis

  delegate :provider_can_use?, to: :account, allow_nil: true
  delegate :default_api_backend, to: :class

  validates :name,        length: { maximum: 511 }, presence: true
  validates :state,       length: { maximum: 255 }
  validates :system_name, length: { maximum: 255 }, presence: true

  validates :private_endpoint, length: { maximum: 255 },
    presence: true,
    uri: { path: proc { provider_can_use?(:proxy_private_base_path) } },
    non_localhost: { message: :protected_domain }

  alias_attribute :api_backend, :private_endpoint

  before_validation :set_private_endpoint, :set_port_private_endpoint
  after_create :create_default_metrics

  has_system_name(uniqueness_scope: [:account_id])

  scope :orphans, -> { joining { services.outer }.where { BabySqueel[:backend_api_configs].backend_api_id == nil } }

  scope :oldest_first, -> { order(created_at: :asc) }
  scope :accessible, -> { where.not(state: DELETED_STATE) }

  state_machine initial: :published do
    state :published
    state DELETED_STATE

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

  private

  def schedule_deletion
    DeleteObjectHierarchyWorker.perform_later(self)
  end

  def set_private_endpoint
    return if account.provider_can_use?(:api_as_product)
    self.private_endpoint ||= default_api_backend
  end

  def set_port_private_endpoint
    Proxy::PortGenerator.new(self).call(:private_endpoint)
  end
end
