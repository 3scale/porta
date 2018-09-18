require 'test_helper'

class Logic::ProviderConstraintTest < ActiveSupport::TestCase

  def test_service_count
    account = FactoryGirl.create(:simple_provider)
    assert_equal 0, account.service_count

    FactoryGirl.create(:simple_service, account: account)
    assert_equal 1, account.service_count
  end

  def test_user_count
    account = FactoryGirl.create(:simple_provider)
    assert_equal 0, account.user_count

    FactoryGirl.create(:simple_user, account: account, role: :member)
    assert_equal 1, account.user_count

    FactoryGirl.create(:simple_user, account: account, role: :admin)
    assert_equal 2, account.user_count
  end
end
