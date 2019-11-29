require 'test_helper'

class ServicePlanTest < ActiveSupport::TestCase

  test "deleting a service should not crash in service_plan#master?" do
    service_plan = FactoryBot.create :service_plan
    service_plan.service.destroy

    refute service_plan.master?
  end
end
