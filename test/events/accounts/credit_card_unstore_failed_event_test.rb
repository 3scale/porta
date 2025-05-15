require 'test_helper'

class Accounts::CreditCardUnstoreFailedEventTest < ActiveSupport::TestCase

  def test_create
    provider = FactoryBot.build(:simple_provider)
    buyer = FactoryBot.build_stubbed(:buyer_account, id: 1, provider: provider)
    event = Accounts::CreditCardUnstoreFailedEvent.create(buyer, "just a test")

    assert event
    assert_equal buyer.org_name, event.buyer_name
    assert_equal "just a test", event.reason
    assert_equal buyer.provider_account.id, event.metadata[:provider_id]
  end
end
