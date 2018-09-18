require 'test_helper'

class AccountObserverTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def setup
    @account = FactoryGirl.create(:simple_buyer)
  end

  def test_after_delete
    skip 'how to test after_delete callback?'
  end

  def test_after_destroy_event
    Accounts::AccountDeletedEvent.expects(:create).once

    @account.destroy
  end

  def test_after_destroy
    @account.provider_account = FactoryGirl.create(:simple_provider)
    EventStore::Repository::Facade.stubs(raise_errors: true)

    @account.destroy
  end
end
