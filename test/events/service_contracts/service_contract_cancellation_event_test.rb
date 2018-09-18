require 'test_helper'

class ServiceContracts::ServiceContractCancellationEventTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def test_create
    service  = FactoryGirl.build_stubbed(:simple_service, id: 1)
    plan     = FactoryGirl.build_stubbed(:simple_service_plan, id: 2, issuer: service)
    contract = FactoryGirl.build_stubbed(:simple_service_contract, id: 3, plan: plan)
    event    = ServiceContracts::ServiceContractCancellationEvent.create(contract)

    assert event
    assert_equal event.plan_name, plan.name
    assert_equal event.service_name, service.name
    assert_equal event.provider, contract.provider_account
    assert_equal event.service, contract.issuer
    assert_equal event.account_id, contract.buyer_account.id
    assert_equal event.account_name, contract.buyer_account.name
  end

  def test_valid?
    service  = FactoryGirl.build_stubbed(:simple_service, id: 1)
    plan     = FactoryGirl.build_stubbed(:simple_service_plan, id: 2, issuer: service)
    contract = FactoryGirl.build_stubbed(:simple_service_contract, id: 3, plan: plan)

    assert ServiceContracts::ServiceContractCancellationEvent.valid?(contract)

    contract.expects(:issuer).returns(nil)

    refute ServiceContracts::ServiceContractCancellationEvent.valid?(contract)
  end

  def test_create_and_publish
    service  = FactoryGirl.build_stubbed(:simple_service, id: 1)
    plan     = FactoryGirl.build_stubbed(:simple_service_plan, id: 2, issuer: service)
    contract = FactoryGirl.build_stubbed(:simple_service_contract, id: 3, plan: plan)

    ServiceContracts::ServiceContractCancellationEvent.expects(:create).once
    ServiceContracts::ServiceContractCancellationEvent.create_and_publish!(contract)

    contract.expects(:issuer).returns(nil)
    ServiceContracts::ServiceContractCancellationEvent.expects(:create).never
    ServiceContracts::ServiceContractCancellationEvent.create_and_publish!(contract)
  end
end
