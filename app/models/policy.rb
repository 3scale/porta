# frozen_string_literal: true

class Policy < ApplicationRecord
  BUILT_IN_NAME = 'builtin'

  belongs_to :account, inverse_of: :policies

  validates :version, uniqueness: { scope: %i[account_id name] }
  validates :name, :version, :account_id, :schema, presence: true
  validate :belongs_to_a_tenant
  validate :validate_schema_specification
  validate :validate_same_version
  validate :validate_not_in_use, on: :update, if: :readonly_attributes_changed?
  before_destroy :validate_not_in_use

  READONLY_ATTRIBUTES = %i[name version schema].freeze

  serialize :schema, ActiveRecord::Coders::JSON

  # Overriding attribute but that is OK
  def schema=(value)
    json = value.is_a?(String) ? ActiveRecord::Coders::JSON.load(value.strip) : value
    super(json)
  rescue JSON::ParserError
    errors.add(:schema, :invalid_json)
  end

  before_validation :set_identifier
  validates :identifier, uniqueness: { scope: :account_id }
  validates :name, :version, length: { maximum: 255 }

  def self.find_by_id_or_name_version(id_or_name_version)
    where.has { (id == id_or_name_version) | (identifier == id_or_name_version) }.first
  end

  def self.find_by_id_or_name_version!(id_or_name_version)
    find_by_id_or_name_version(id_or_name_version) || raise(ActiveRecord::RecordNotFound)
  end

  def to_param
    persisted? ? identifier : nil
  end

  def directory
    return '' unless name.present? && version.present?
    File.join(name, version)
  end

  def directory=(value)
    self.name = File.dirname(value.to_s)
    self.version = File.basename(value.to_s)
  end

  # That is ugly but only needed by JS
  # FIXME: Do it in the decorator
  def humanName
    schema&.dig('name')
  end

  def summary
    schema&.dig('summary')
  end

  def readonly_attributes_changed?
    (changed_attributes.keys & READONLY_ATTRIBUTES.map(&:to_s)).any?
  end

  def in_use?
    account.proxies.any? { |proxy| proxy.find_policy_config_by name: name_was, version: version_was }
  end

  def idle?
    !in_use?
  end

  private

  def belongs_to_a_tenant
    return if !account || account.tenant?
    errors.add(:account, :not_tenant)
  end

  # Yes it :reek:NilCheck
  def validate_same_version
    if version.to_s == BUILT_IN_NAME
      errors.add :version, :builtin
    elsif version.to_s != schema&.dig('version').to_s
      errors.add(:version, :mismatch)
    end
  end

  def validate_schema_specification
    specification = ThreeScale::Policies::Specification.new(schema)
    return if specification.valid?
    specification.errors[:base].each { |error| errors.add(:schema, error) }
  end

  def validate_not_in_use
    return true if idle?
    errors.add(:base, :currently_in_use)
    throw :abort
  end

  def set_identifier
    self.identifier = "#{name}-#{version}"
  end
end
