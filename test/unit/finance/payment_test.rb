# frozen_string_literal: true

require 'test_helper'

class Finance::PaymentTest < ActiveSupport::TestCase
  include BillingResultsTestHelpers

  test 'GatewayRateLimitError stores payment_metadata' do
    assert Finance::Payment::GatewayRateLimitError < Finance::Payment::GatewayError

    payment_metadata = { invoice_id: 123, buyer_id: 456, payment_method_id: 'pm_test' }
    error = Finance::Payment::GatewayRateLimitError.new(mock_stripe_rate_limit_response, payment_metadata)

    assert_equal payment_metadata, error.payment_metadata
  end

  test 'GatewayRateLimitError fetches message from response or falls back to standard message' do
    response = stub(success?: false, message: 'Rate limit exceeded')
    error = Finance::Payment::GatewayRateLimitError.new(response)
    assert_equal 'Rate limit exceeded', error.message

    error_with_default_message = Finance::Payment::GatewayRateLimitError.new(stub(success?: false, message: nil))
    assert_equal 'Rate limit exceeded - too many requests to payment gateway', error_with_default_message.message
  end
end
