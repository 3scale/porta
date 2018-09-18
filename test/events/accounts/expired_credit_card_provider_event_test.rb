require 'test_helper'

class Accounts::ExpiredCreditCardProviderEventTest < ActiveSupport::TestCase

  def test_create
    buyer = FactoryGirl.build_stubbed(:buyer_account, id: 1,
                                        provider_account_id: 2)
    event = Accounts::ExpiredCreditCardProviderEvent.create(buyer)

    assert event
    assert_equal event.account, buyer
    assert_equal event.provider, buyer.provider_account
  end
end
