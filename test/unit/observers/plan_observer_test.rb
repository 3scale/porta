require 'test_helper'

class PlanObserverTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def test_plan_downgraded
    contract = FactoryGirl.create(:service_contract,
      plan: FactoryGirl.create(:service_plan, cost_per_month: 30))

    Plans::PlanDowngradedEvent.expects(:create).once

    contract.change_plan! FactoryGirl.create(:service_plan, cost_per_month: 20)
  end
end
