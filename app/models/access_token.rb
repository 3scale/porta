class AccessToken < ApplicationRecord
  belongs_to :owner, class_name: 'User', inverse_of: :access_tokens

  serialize :scopes, Array

  def self.options_to_hash(options)
    options.map do |key|
      [I18n.t(key, scope: :access_token_options), key]
    end.to_h
  end

  scope :by_name, ->(name) { name.present? ? where("name LIKE ?", "%#{name}%") : all }

  PERMISSIONS = options_to_hash(%w[ro rw]).freeze
  SCOPES      = options_to_hash(%w[cms finance account_management stats policy_registry]).freeze

  Scope = Struct.new(:key, :value) do

    def permission_name
      case value
      when 'stats' then :monitoring
      when 'account_management' then :partners
      when 'cms' then :portal
      else value.to_s.to_sym
      end
    end

    def public?
      non_public_scopes.exclude?(value.to_s)
    end

    private

    def non_public_scopes
      %w(cms).freeze
    end
  end

  class Scopes
    extend Forwardable

    delegate %i(each count select any? map) => :scopes

    def initialize(scopes)
      @scopes = scopes
    end

    def allowed_for(owner)
      select_and_build do |scope|
        owner.has_permission?(scope.permission_name)
      end
    end

    def visible_for(account)
      select_and_build do |scope|
        if scope.public?
          true
        else
          account.provider_can_use?("#{scope.value}_api")
        end
      end
    end

    def keys
      scopes.map(&:key)
    end

    def values
      scopes.map(&:value)
    end

    def to_a
      map { |scope| [scope.key, scope.value] }
    end

    private

    def select_and_build(&block)
      self.class.new(select(&block))
    end

    attr_reader :scopes
  end

  class ScopesFactory
    def self.build(scopes)
      Scopes.new(scopes.map { |key, value| Scope.new(key, value) })
    end
  end

  def self.scopes
    ScopesFactory.build(allowed_scopes)
  end

  def self.allowed_scopes
    if ThreeScale.master_on_premises?
      SCOPES.except(I18n.t(:finance, scope: :access_token_options))
            .except(I18n.t(:cms, scope: :access_token_options))
    else
      SCOPES
    end
  end

  validates :owner, :value, :name, :permission, presence: true
  validates :value, uniqueness: { scope: [:owner_id] }, length: { maximum: 255 }
  validates :permission, inclusion: { in: PERMISSIONS.values }, length: { maximum: 255 }
  validates :scopes, length: { minimum: 1, maximum: 65535 }
  validate :validate_scope_exists

  after_initialize :generate_value

  attr_accessible :owner, :name, :scopes, :permission

  attr_readonly :value

  # will be removed once deployed
  def self.columns
    super.reject { |column| column.name == 'owner_type' }
  end

  def self.find_from_value(value)
    find_by(value: value.to_s.scrub)
  rescue ActiveRecord::StatementInvalid, ArgumentError # utf-8 issues
    nil
  end

  def self.find_from_id_or_value!(id_or_value)
    find_from_id_or_value(id_or_value) or raise(ActiveRecord::RecordNotFound)
  end

  def self.find_from_id_or_value(id_or_value)
    find_by(id: id_or_value) || find_from_value(id_or_value)
  end

  # This can't change or it will create new tokens for everyone
  OIDC_SYNC_TOKEN = 'OIDC Synchronization Token'.freeze

  def self.oidc_sync
    create_with(scopes: %w[account_management], permission: 'ro').find_or_create_by!(name: OIDC_SYNC_TOKEN)
  end

  def scopes=(values)
    super Array(values).select(&:present?)
  end

  def validate_scope_exists
    # We allow to create non allowed scopes for the member user specifically but we don't allow to authenticate with them.
    # More info in https://github.com/3scale/porta/pull/430#discussion_r242879832
    scopes_allowed_values = self.class.allowed_scopes.values
    return true if Array(scopes).all? { |scope| scopes_allowed_values.include? scope }
    errors.add :scopes, :invalid
  end

  def generate_value
    self.value ||= self.class.random_id
  end

  def available_permissions
    PERMISSIONS
  end

  def human_permission
    PERMISSIONS.key(permission)
  end

  def show_value?(*)
    previous_changes.include?(:value)
  end

  def available_scopes
    owner.allowed_access_token_scopes.visible_for(owner.account)
  end

  def human_scopes
    scopes.map { |scope| SCOPES.key(scope) }.compact
  end

  def self.random_id
    SecureRandom.hex(32)
  end
end
