# frozen_string_literal: true

class NestedAssociationValidator < ActiveModel::EachValidator
  def initialize(options)
    raise ArgumentError, 'No `:report` key found' unless options.key?(:report)
    super
  end

  def validate_each(record, _attribute, value)
    return if !value || value.valid? || value.marked_for_destruction?
    options[:report].each do |alternate, attr|
      errors = value.errors.where(alternate)
      record_attr = attr || alternate
      errors.each do |error|
        record.errors.add(record_attr, error.type)
      end
    end
  end
end
