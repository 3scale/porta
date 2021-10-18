require 'test_helper'

class ServicePlanTest < ActiveSupport::TestCase

  test "deleting a service should not crash in service_plan#master?" do
    service_plan = FactoryBot.create :service_plan
    service_plan.service.destroy

    refute service_plan.master?
  end

  test "deleting a service plan will be stopped if service contract deletion fails" do
    ServiceContract.any_instance.stubs(:destroy).returns(false)

    contract = FactoryBot.create(:service_contract)
    service_plan = contract.service_plan

    refute contract.service_plan.destroy
    assert_not_nil ServiceContract.find_by(id: contract.id)
    assert_not_nil ServicePlan.find_by(id: service_plan.id)
  end
end
