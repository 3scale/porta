require 'test_helper'

class Accounts::AccountPlanChangeRequestedEventTest < ActiveSupport::TestCase

  def test_create
    provider = FactoryBot.build(:simple_provider, id: 1)
    plan    = FactoryBot.build_stubbed(:simple_account_plan, id: 1)
    plan_2  = FactoryBot.build_stubbed(:simple_account_plan, id: 2)
    account = FactoryBot.build_stubbed(:buyer_account, id: 3, bought_account_plan: plan_2, provider_account: provider)
    user    = FactoryBot.build_stubbed(:simple_user, account: account)
    event   = Accounts::AccountPlanChangeRequestedEvent.create(account, user, plan)

    assert event
    assert_equal event.account, account
    assert_equal event.user, user
    assert_equal event.provider, account.provider_account
    assert_equal event.requested_plan, plan
    assert_equal event.current_plan, plan_2
  end
end
