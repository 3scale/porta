# frozen_string_literal: true

require 'test_helper'

class ServicePlanTest < ActiveSupport::TestCase
  test "deleting a service should not crash in service_plan#master?" do
    service_plan = FactoryBot.create(:service_plan)
    service_plan.service.destroy

    assert_not service_plan.master?
  end

  test "deleting a service plan will be stopped if service contract deletion fails" do
    ServiceContract.any_instance.stubs(:destroy).returns(false)

    contract = FactoryBot.create(:service_contract)
    service_plan = contract.service_plan

    assert_not contract.service_plan.destroy
    assert_not_nil ServiceContract.find_by(id: contract.id)
    assert_not_nil ServicePlan.find_by(id: service_plan.id)
  end

  test 'destroy custom service plans if its single buyer is destroyed' do
    custom_service_plan = FactoryBot.create(:simple_service_plan).customize
    buyer = FactoryBot.create(:simple_buyer)
    buyer.buy! custom_service_plan
    buyer.destroy
    assert buyer.destroyed?
    assert_raise ActiveRecord::RecordNotFound do
      custom_service_plan.reload
    end
  end

  test '.provided_by scope' do
    provider1 = FactoryBot.create(:simple_provider)
    provider2 = FactoryBot.create(:simple_provider)
    p1_service1 = FactoryBot.create(:simple_service, account: provider1)
    p1_service2 = FactoryBot.create(:simple_service, account: provider1)
    p2_service3 = FactoryBot.create(:simple_service, account: provider2)

    # Default service plans are created on service creation, we destroy them for a clean comparison
    p1_service1.service_plans.destroy_all
    p1_service2.service_plans.destroy_all
    p2_service3.service_plans.destroy_all

    p1_plans = FactoryBot.create_list(:simple_service_plan, 3, issuer: p1_service1) +
               FactoryBot.create_list(:simple_service_plan, 4, issuer: p1_service2)
    p2_plans = FactoryBot.create_list(:simple_service_plan, 2, issuer: p2_service3)

    assert_same_elements p1_plans, ServicePlan.provided_by(provider1).to_a
    assert_same_elements p2_plans, ServicePlan.provided_by(provider2).to_a
  end
end
