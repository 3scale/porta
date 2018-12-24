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
    user = account.admins.first!

    event = Accounts::AccountDeletedEvent.create(account)
    account.destroy!

    assert_equal user.id, event.user_id
    assert_equal current_user.id, event.metadata[:user_id] # user who destroyed the account
  end

  def test_first_admin_user_already_deleted
    provider = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:admin, account: provider)
    user_id = user.id
    provider.update_column(:first_admin_id, user_id)
    user.delete

    event = Accounts::AccountDeletedEvent.create(provider)
    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal user_id, event_stored.user_id
  end
end
