require 'test_helper'

class PlansHelperTest < ActionView::TestCase

  def test_can_create_plan
    stubs(:can?).with(:create, :account_plans).returns(true)
    assert can_create_plan?(AccountPlan)

    stubs(:can?).with(:create, :plans).returns(true)
    assert can_create_plan?(Plan)

    stubs(:can?).with(:create, :plans).returns(false)
    refute can_create_plan?(ApplicationPlan)

    stubs(:can?).with(:create, :account_plans).returns(false)
    stubs(:can?).with(:create, AccountPlan).returns(true)
    assert can_create_plan?(AccountPlan)
  end

end
