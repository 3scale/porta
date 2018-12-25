require 'test_helper'

class Services::ServicePlanChangeRequestedEventTest < ActiveSupport::TestCase

  def test_create
    provider       = FactoryBot.build_stubbed(:simple_provider)
    service        = FactoryBot.build_stubbed(:simple_service, account: provider)
    user           = FactoryBot.build_stubbed(:simple_user)
    account        = FactoryBot.build_stubbed(:simple_account, id: 3)
    requested_plan = FactoryBot.build_stubbed(:simple_plan, id: 1, issuer: service)
    requested_plan.stubs(:provider_account).returns(provider)
    contract       = FactoryBot.build_stubbed(:simple_service_contract, user_account: account)

    event = Services::ServicePlanChangeRequestedEvent.create(contract, user, requested_plan)

    assert event
    assert_equal account, event.account
    assert_equal contract.issuer, event.service
    assert_equal user, event.user
    assert_equal requested_plan, event.requested_plan
    assert_equal contract.service_plan, event.current_plan
  end
end
