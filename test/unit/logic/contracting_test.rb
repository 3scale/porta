require 'test_helper'

class Logic::ContractingTest < ActiveSupport::TestCase

  def test_can_create_application_contract
    provider = FactoryGirl.create(:simple_provider)
    not_available = FactoryGirl.create(:simple_service, account: provider)
    _plan = FactoryGirl.create(:simple_application_plan, issuer: not_available)
    with_default_plan = FactoryGirl.create(:simple_service, account: provider)
    with_default_plan.update_columns(default_application_plan_id: 42)
    with_published_plan = FactoryGirl.create(:simple_service, account: provider)
    published_plan1 = FactoryGirl.create(:simple_application_plan, issuer: with_published_plan)
    published_plan2 = FactoryGirl.create(:simple_application_plan, issuer: with_published_plan)
    [ published_plan1, published_plan2 ].each { |plan| plan.update_columns(state: 'published') }

    available = provider.services.can_create_application_contract.order(:id)

    assert_equal [with_default_plan, with_published_plan], available.to_a
  end

  def test_services_can_create_app_on
    provider = FactoryGirl.create(:simple_provider)
    buyer = FactoryGirl.create(:simple_buyer, provider_account: provider)
    service_with_contract = FactoryGirl.create(:simple_service, account: provider)
    plan = FactoryGirl.create(:simple_service_plan, issuer: service_with_contract)
    _contract = FactoryGirl.create(:simple_service_contract, plan: plan, user_account: buyer)
    _service_without = FactoryGirl.create(:simple_service, account: provider)
    service_with_plan = FactoryGirl.create(:simple_service, account: provider)
    service_with_plan.update_columns(default_application_plan_id: 42)

    available = buyer.services_can_create_app_on

    assert_equal 0, available.count

    service_with_contract.update_columns(default_application_plan_id: 42)

    assert_equal 1, available.count
  end
end
