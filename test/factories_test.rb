require 'test_helper'

class FactoriesTest < ActiveSupport::TestCase
  def test_payment_gateway_settings_of_provider_account
    provider_account = FactoryGirl.create(:provider_account,
    payment_gateway_options: {key: 'hello', value: 'world'},
    payment_gateway_type: 'stripe'
                                         )
    provider_account.reload
    assert_equal({key: 'hello', value: 'world'}, provider_account.payment_gateway_options)
    assert_equal :stripe, provider_account.payment_gateway_type
  end
end
