# frozen_string_literal: true

class Policy < ApplicationRecord
  belongs_to :account

  validates :version, uniqueness: { scope: %i[account_id name] }
  validates :name, :version, :account_id, :schema, presence: true
  validate :belongs_to_a_tenant
  validate :validate_schema_specification

  def self.find_by_id_or_name_version(id_or_name_version)
    id_or_name, version = extract_identifier(id_or_name_version)
    find_by version.present? ? { name: id_or_name, version: version } : { id: id_or_name.to_i }
  end

  def self.find_by_id_or_name_version!(id_or_name_version)
    id_or_name, version = extract_identifier(id_or_name_version)
    find_by! version.present? ? { name: id_or_name, version: version } : { id: id_or_name.to_i }
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

  class << self
    private

    def extract_identifier(id_or_name_version)
      *name_parts, id_or_version = id_or_name_version.to_s.split('-')
      [name_parts.join('-').presence, id_or_version].compact
    end
  end
end
