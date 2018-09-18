require 'test_helper'

class ApplicationValidatorTest < ActiveSupport::TestCase

  class DoubleValidator < ApplicationValidator
    validate :validate_double

    def validate_double
      true
    end
  end

  def test_valid?
    validator = DoubleValidator.new
    validator.expects(:validate_double).once
    validator.valid?
    validator.valid?
  end
end
