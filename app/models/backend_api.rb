# frozen_string_literal: true

class BackendApi < ApplicationRecord

  include SystemName
  ECHO_API_HOST = 'echo-api.3scale.net'

  has_many :backend_api_configs, inverse_of: :backend_api, dependent: :destroy
  has_many :services, through: :backend_api_configs
  belongs_to :account, inverse_of: :backend_apis

  delegate :provider_can_use?, to: :account

  validates :private_endpoint, length: { maximum: 255 },
    presence: true,
    uri: { path: proc { provider_can_use?(:proxy_private_base_path) } },
    non_localhost: { message: :protected_domain }

  alias_attribute :api_backend, :private_endpoint

  before_validation :set_private_endpoint, :set_port_private_endpoint

  has_system_name(uniqueness_scope: [:account_id])

  def default_api_backend
    "https://#{ECHO_API_HOST}:443"
  end

  def set_private_endpoint
    self.private_endpoint ||= default_api_backend
  end

  def set_port_private_endpoint
    Proxy::PortGenerator.new(self).call(:private_endpoint)
  end
end
