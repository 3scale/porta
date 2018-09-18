require 'test_helper'

class Accounts::AccountStateChangedEventTest < ActiveSupport::TestCase

  def test_create
    account = FactoryGirl.build_stubbed(:simple_buyer, id: 1, state: 'pending',
                                          provider_account_id: 2)
    event   = Accounts::AccountStateChangedEvent.create(account, 'created')

    assert event
    assert_equal event.account, account
    assert_equal event.state, account.state
    assert_equal event.previous_state, 'created'
    assert_equal event.provider, account.provider_account
  end
end
