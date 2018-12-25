require 'test_helper'

class ServicePlanTest < ActiveSupport::TestCase

  test "airbrake 56114002" do
    service_plan = FactoryBot.create :service_plan
    service_plan.service.destroy

    refute service_plan.master?
  end
end
