require 'test_helper'

class ServiceContracts::ServiceContractPlanChangedEventTest < ActiveSupport::TestCase

  def test_create
    provider = FactoryBot.build_stubbed(:simple_provider)
    account  = FactoryBot.build_stubbed(:buyer_account, provider_account: provider)
    service = FactoryBot.build_stubbed(:simple_service, account: provider)
    plan = FactoryBot.build_stubbed(:simple_service_plan, service: service, issuer: service)
    contract = FactoryBot.build_stubbed(:simple_service_contract, id: 1, plan: plan, user_account: account)
    user     = FactoryBot.build_stubbed(:simple_user, account: account)
    contract.stubs(:old_plan).returns(FactoryBot.build_stubbed(:simple_service_plan, id: 2))
    event    = ServiceContracts::ServiceContractPlanChangedEvent.create(contract, user)

    assert event
    assert_equal event.service_contract, contract
    assert_equal event.new_plan, contract.plan
    assert_equal event.old_plan, contract.old_plan
    assert_equal event.provider, contract.provider_account
    assert_equal event.user, user
    assert_equal event.account, account
    assert_equal event.service, contract.issuer
  end
end
