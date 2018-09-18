require 'test_helper'

class Accounts::AccountDeletedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def test_create
    account = FactoryGirl.build_stubbed(:simple_buyer, id: 1, provider_account_id: 2)
    event   = Accounts::AccountDeletedEvent.create(account)

    assert event
    assert_equal account.id, event.account_id
    assert_equal account.provider_account, event.provider
    assert_equal event.metadata[:provider_id], account.provider_account_id
  end

  def test_destroy
    current_user = User.current = FactoryGirl.create(:simple_user)

    account = FactoryGirl.create(:provider_account)
    user = account.users.first!

    event = Accounts::AccountDeletedEvent.create(account)
    account.destroy!

    assert_equal user.id, event.user_id
    assert_equal current_user.id, event.metadata[:user_id] # user who destroyed the account
  end
end
