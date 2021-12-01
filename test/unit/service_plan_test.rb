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
end
