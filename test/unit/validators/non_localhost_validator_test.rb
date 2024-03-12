# frozen_string_literal: true

require 'test_helper'

class NonLocalhostValidatorTest < ActiveSupport::TestCase

  def test_validate_each

    validator = NonLocalhostValidator.new(attributes: [:api_backend])

    record = FactoryBot.build_stubbed(:proxy)

    errors = validator.validate_each(record, :api_backend, 'http://other_word/')
    assert_nil errors
    assert record.errors.empty?

    error = validator.validate_each(record, :api_backend, 'http://localhost/')
    assert_equal ActiveModel::Error, error.class
    assert "can't be localhost", record.errors.messages_for(:api_backend)

    record = FactoryBot.build_stubbed(:proxy)
    error = validator.validate_each(record, :api_backend, 'http://mylocalhost/')
    assert_nil error
    assert record.errors.empty?

    error = validator.validate_each(record, :api_backend, ' http://34.210.51.155:8181')
    assert_equal ActiveModel::Error, error.class
    assert "Invalid URL format", record.errors.messages_for(:api_backend)

    error = validator.validate_each(record, :api_backend, 'hrdt://smth')
    assert_nil error
    assert record.errors.present?

    error = validator.validate_each(record, :api_backend, '')
    assert_nil error
    assert record.errors.present?

    error = validator.validate_each(record, :api_backend, nil)
    assert_nil error
    assert record.errors.present?

    error = validator.validate_each(record, :api_backend, 'https://<yours>')
    assert "Invalid URL format", error.message
    assert record.errors.present?
  end
end
