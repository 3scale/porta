require 'test_helper'

class Accounts::ExpiredCreditCardProviderEventTest < ActiveSupport::TestCase

  def test_create
    provider = FactoryBot.build(:simple_provider)
    buyer = FactoryBot.build_stubbed(:buyer_account, id: 1, provider: provider)
    event = Accounts::ExpiredCreditCardProviderEvent.create(buyer)

    assert event
    assert_equal event.account, buyer
    assert_equal event.provider, buyer.provider_account
  end
end
