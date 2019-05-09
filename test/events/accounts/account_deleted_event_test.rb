require 'test_helper'

class Accounts::AccountDeletedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def test_create
    account = FactoryBot.build_stubbed(:simple_buyer, id: 1, provider_account_id: 2)
    event   = Accounts::AccountDeletedEvent.create(account)

    assert event
    assert_equal account.id, event.account_id
    assert_equal account.provider_account, event.provider
    assert_equal event.metadata[:provider_id], account.provider_account_id
  end

  def test_destroy
    current_user = User.current = FactoryBot.create(:simple_user)

    account = FactoryBot.create(:provider_account)

    event = Accounts::AccountDeletedEvent.create(account)
    account.destroy!

    assert_equal current_user.id, event.metadata[:user_id] # user who destroyed the account
  end
end
