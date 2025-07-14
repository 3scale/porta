require 'test_helper'

class PlanObserverTest < ActiveSupport::TestCase

  def test_plan_downgraded
    service = FactoryBot.create(:service)
    contract = FactoryBot.create(:service_contract,
                                 plan: FactoryBot.create(:service_plan, issuer: service, cost_per_month: 30))
    another_plan = FactoryBot.create(:service_plan, issuer: service, cost_per_month: 20)

    Plans::PlanDowngradedEvent.expects(:create).once

    contract.change_plan! another_plan
  end
end
