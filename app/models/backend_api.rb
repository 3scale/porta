# frozen_string_literal: true

class BackendApi < ApplicationRecord

  include SystemName
  ECHO_API_HOST = 'echo-api.3scale.net'

  has_many :proxy_rules, as: :owner, dependent: :destroy, inverse_of: :owner

  has_many :backend_api_configs, inverse_of: :backend_api, dependent: :destroy
  has_many :services, through: :backend_api_configs
  belongs_to :account, inverse_of: :backend_apis

  delegate :provider_can_use?, to: :account, allow_nil: true
  delegate :default_api_backend, to: :class

  validates :name,        length: { maximum: 511 }, presence: true
  validates :system_name, length: { maximum: 255 }, presence: true

  validates :private_endpoint, length: { maximum: 255 },
    presence: true,
    uri: { path: proc { provider_can_use?(:proxy_private_base_path) } },
    non_localhost: { message: :protected_domain }

  alias_attribute :api_backend, :private_endpoint

  before_validation :set_private_endpoint, :set_port_private_endpoint

  has_system_name(uniqueness_scope: [:account_id])

  def self.default_api_backend
    "https://#{ECHO_API_HOST}:443"
  end

  def first_service
    backend_api_configs.first&.service
  end

  private

  def set_private_endpoint
    self.private_endpoint ||= default_api_backend
  end

  def set_port_private_endpoint
    Proxy::PortGenerator.new(self).call(:private_endpoint)
  end
end
