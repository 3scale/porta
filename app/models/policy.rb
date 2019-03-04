# frozen_string_literal: true

class Policy < ApplicationRecord
  belongs_to :account, inverse_of: :policies

  validates :version, uniqueness: { scope: %i[account_id name] }
  validates :name, :version, :account_id, :schema, presence: true
  validate :belongs_to_a_tenant
  validate :validate_schema_specification
  serialize :schema, ActiveRecord::Coders::JSON

  # Overriding attribute but that is OK
  def schema=(value)
    json = value.is_a?(String) ? ActiveRecord::Coders::JSON.load(value.strip) : value
    super(json)
  rescue JSON::ParserError
    errors.add(:schema, :invalid_json)
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
end
