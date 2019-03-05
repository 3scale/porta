# frozen_string_literal: true

class Policy < ApplicationRecord
  belongs_to :account, inverse_of: :policies

  validates :version, uniqueness: { scope: %i[account_id name] }
  validates :name, :version, :account_id, :schema, presence: true
  validate :belongs_to_a_tenant
  validate :validate_schema_specification

  before_validation :set_identifier
  validates :identifier, uniqueness: { scope: :account_id }

  def self.find_by_id_or_name_version(id_or_name_version)
    where.has { (id == id_or_name_version) | (identifier == id_or_name_version) }.first
  end

  def self.find_by_id_or_name_version!(id_or_name_version)
    find_by_id_or_name_version(id_or_name_version) || raise(ActiveRecord::RecordNotFound)
  end

  private

  def belongs_to_a_tenant
    return if !account || account.tenant?
    errors.add(:account, :not_tenant)
  end

  def validate_schema_specification
    specification = ThreeScale::Policies::Specification.new(schema)
    return if specification.valid?
    specification.errors[:base].each { |error| errors.add(:schema, error) }
  end

  def set_identifier
    self.identifier = "#{name}-#{version}"
  end
end
