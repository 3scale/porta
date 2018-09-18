require 'test_helper'

class Finance::NoVariableCostClass < ActiveSupport::TestCase

  def test_bill_for_variable
    contract = FactoryGirl.build_stubbed(:contract)
    account  = FactoryGirl.build_stubbed(:simple_account)
    app_plan = FactoryGirl.build_stubbed(:application_plan)

    contract.stubs(:provider_account).returns(account)
    account.stubs(:provider_can_use?).returns(true)

    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end
end
