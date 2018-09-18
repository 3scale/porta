# frozen_string_literal: true

class ApplicationValidator
  include ActiveModel::Validations

  def valid?
    return @validator_valid if instance_variable_defined?(:@validator_valid)
    @validator_valid = super
  end
end
