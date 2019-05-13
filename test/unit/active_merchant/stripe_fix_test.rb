# frozen_string_literal: true
require 'test_helper'

class StripeFixTest < ActiveSupport::TestCase
  def test_threescale_unstore
    System::Application.config.three_scale.payments.stubs(enabled: true)
    stripe = ActiveMerchant::Billing::StripeGateway.new login: 'apitoken'

    auth = Base64.strict_encode64('apitoken:')
    request = stub_request(:delete, "https://api.stripe.com/v1/customers/credit_card_auth_code").with(headers: {Authorization: "Basic #{auth}"}).
      to_return(:status => 200, :body => '{}', :headers => {})
    stripe.threescale_unstore('credit_card_auth_code')

    assert_requested request
  end
end
