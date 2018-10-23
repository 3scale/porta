# frozen_string_literal: true

class AuthenticationProvider < ApplicationRecord
  belongs_to :account
  has_many :sso_authorizations, dependent: :delete_all

  class_attribute :authorization_scope, :oauth_config_required, :can_be_published
  self.oauth_config_required = true
  self.can_be_published = true

  include SystemName

  enum account_type: {developer: 'developer', provider: 'provider'}

  has_system_name uniqueness_scope: [:account_id]
  validates :kind, uniqueness: { scope: %i[account_id account_type] }, if: :developer?
  validate  :verify_valid_kind_for_account_type
  validates :name, presence: true, length: { maximum: 255 }
  validates :identifier_key, presence: true, length: { maximum: 255 }
  validates :system_name, :client_id, :client_secret, :token_url, :user_info_url,
            :authorize_url, :site, :username_key, :kind, :branding_state, :type,
            length: { maximum: 255 }

  validates :system_name, exclusion: [
      RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME,
      ServiceDiscovery::AuthenticationProviderSupport::SERVICE_DISCOVERY_SYSTEM_NAME
  ]

  before_validation :set_defaults, on: :create
  before_create :set_defaults

  validates :client_id, :client_secret, presence: true, if: :oauth_config_required?

  with_options format: { with: URI.regexp(%w(http https)), allow_blank: true, message: :invalid_url } do |ops|
    ops.validates :site
    ops.validates :token_url
    ops.validates :authorize_url
    ops.validates :user_info_url
  end

  attr_readonly :type, :kind

  scope(:published, -> { where(published: true) })

  AVAILABLE = {
    account_types[:developer] => %w[Keycloak Auth0 GitHub],
    account_types[:provider]  => %w[Keycloak Auth0]
  }.freeze
  private_constant :AVAILABLE

  def self.available(account_type = account_types[:developer])
    AVAILABLE[account_type].map(&method(:const_get)) # Done this way because otherwise it understands GitHub as the module in github-markdown gem
  end

  def self.find_kind(kind, available_kinds = available)
    available_kinds.find do |model|
      model.model_name.element == kind
    end
  end

  def self.build_by_kind(kind:, account_type:, **attributes)
    kind_downcased = kind.to_s.downcase
    kind_class = find_kind(kind_downcased, available(account_type)) || Custom
    kind_class.new({kind: kind_downcased, account_type: account_type}.reverse_merge(attributes))
  end

  Credentials = Struct.new(:client_id, :client_secret)

  # @return [Credentials]
  def credentials
    Credentials.new(client_id.presence, client_secret.presence)
  end

  alias callback_account account

  def authorization_scope(action = nil)
    self.class.authorization_scope
  end

  def ready_to_be_custom_branded?
    in_social_scope? && client_id_and_client_secret?
  end

  def can_switch_at_will?
    custom_branded? || ready_to_be_custom_branded?
  end

  def in_iam_tools_scope?
    authorization_scope == :iam_tools
  end

  def in_social_scope?
    authorization_scope == :branding
  end

  alias has_3scale_branded_equivalent? in_social_scope?

  def client_id_and_client_secret?
    client_id.present? && client_secret.present?
  end

  def human_state_name
    I18n.t(branding_state_name, scope: [:authentication_provider, :state])
  end

  def self.human_kind
    I18n.t(kind, scope: [:authentication_provider, :kind], default: model_name.human)
  end

  def allowed_state_transitions
    branding_state_transitions.map do |transition|
      [I18n.t(transition.to_name, scope: [:authentication_provider, :state]), transition.event]
    end
  end

  def ssl_verify_mode
    skip_ssl_certificate_verification? ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
  end

  def self.kind
    model_name.element.freeze
  end

  def kind
    super || self.class.kind
  end

  delegate :human_kind, to: :class

  def self.branded_available?
    config = ThreeScale::OAuth2.config.fetch(kind, {})

    return unless config[:enabled]

    credentials = config.slice(:client_id, :client_secret)
    credentials.values.any?(&:present?)
  end

  private

  def verify_valid_kind_for_account_type
    my_class = self.class
    return if developer? || (provider? && my_class.available(my_class.account_types[:provider]).include?(my_class))
    errors.add(:kind, :not_found)
    false
  end

  def set_defaults
    self.system_name ||= kind.to_s
    self.name ||= human_kind.to_s
  end
end

# to prevent warning: toplevel constant GitHub referenced by AuthenticationProvider::GitHub
require_dependency 'authentication_provider/github'
require_dependency 'authentication_provider/keycloak'
require_dependency 'authentication_provider/auth0'
require_dependency 'authentication_provider/custom'
require_dependency 'authentication_provider/redhat_customer_portal'
