require 'test_helper'

class Plans::PlanDowngradedEventTest < ActiveSupport::TestCase

  def test_create
    provider = FactoryBot.build_stubbed(:simple_provider)
    service  = FactoryBot.build_stubbed(:simple_service, account: provider)
    new_plan = FactoryBot.build_stubbed(:simple_plan, id: 1, issuer: service)
    old_plan = FactoryBot.build_stubbed(:simple_plan, id: 2)
    account  = FactoryBot.build_stubbed(:simple_account, id: 3)
    contract = FactoryBot.build_stubbed(:simple_service_contract, user_account: account)
    new_plan.stubs(:provider_account).returns(provider)
    event    = Plans::PlanDowngradedEvent.create(new_plan, old_plan, contract)

    assert event
    assert_equal event.provider, provider
    assert_equal event.new_plan, new_plan
    assert_equal event.old_plan, old_plan
    assert_equal event.account, account
    assert_equal event.contract, contract
  end
end
