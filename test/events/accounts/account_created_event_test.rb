require 'test_helper'

class Accounts::AccountCreatedEventTest < ActiveSupport::TestCase

  def test_create
    account = FactoryGirl.build_stubbed(:simple_buyer, id: 1,
                                          provider_account_id: 2)
    event   = Accounts::AccountCreatedEvent.create(account, user)

    assert event
    assert_equal event.account, account
    assert_equal event.provider, account.provider_account
    assert_equal event.user, user
    assert_equal event.metadata[:provider_id], 2
  end

  def test_provider
    # master for master
    master = master_account
    event  = Accounts::AccountCreatedEvent.create(master, user)

    assert_equal event.provider, master

    # provider for master
    provider = FactoryGirl.build_stubbed(:simple_provider, provider_account: master)
    event    = Accounts::AccountCreatedEvent.create(provider, user)

    assert_equal event.provider, master

    # buyer for provider
    buyer = FactoryGirl.build_stubbed(:simple_buyer, provider_account: provider)
    event = Accounts::AccountCreatedEvent.create(buyer, user)

    assert_equal event.provider, provider
  end

  private

  def user
    @_user ||= FactoryGirl.build_stubbed(:simple_user)
  end
end
