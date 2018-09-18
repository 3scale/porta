require 'test_helper'

class ThreeScale::LocalhostValidatorTest < ActiveSupport::TestCase

  def test_validate_each

    validator = ThreeScale::LocalhostValidator.new(attributes: [:api_backend])

    record = Proxy.new

    errors = validator.validate_each(record, :api_backend, 'http://other_word/')
    assert_equal nil, errors
    assert record.errors.empty?

    errors = validator.validate_each(record, :api_backend, 'http://localhost/')
    assert_equal ["can't be localhost"], errors
    assert record.errors.present?

    record = Proxy.new
    errors = validator.validate_each(record, :api_backend, ' http://34.210.51.155:8181')
    assert_equal ["Invalid URL format"], errors
    assert record.errors.present?

    errors = validator.validate_each(record, :api_backend, 'hrdt://smth')
    assert_equal nil, errors
    assert record.errors.present?

    errors = validator.validate_each(record, :api_backend, '')
    assert_equal nil, errors
    assert record.errors.present?

    errors = validator.validate_each(record, :api_backend, nil)
    assert_equal nil, errors
    assert record.errors.present?

    errors = validator.validate_each(record, :api_backend, 'https://<yours>')
    assert_includes errors, "Invalid URL format"
    assert record.errors.present?

  end
end