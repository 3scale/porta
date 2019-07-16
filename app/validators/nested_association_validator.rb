# frozen_string_literal: true

class NestedAssociationValidator < ActiveModel::EachValidator
  def initialize(options)
    raise ArgumentError, 'No `:report` key found' unless options.key?(:report)
    super
  end

  def validate_each(record, attribute, value)
    return if !value || value.valid? || value.marked_for_destruction?
    options[:report].each do |alternate, attr|
      errors = value.errors.get(alternate)
      record.errors[attr || alternate].concat(errors) if errors.present?
    end
  end
end
