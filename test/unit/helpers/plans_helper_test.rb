require 'test_helper'

class PlansHelperTest < ActionView::TestCase
  include PlansHelper

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

  test 'account_plans_management_visible?' do
    tenant = FactoryBot.create(:simple_provider)
    stubs(current_account: tenant)

    stubs(:can?).with(:manage, :account_plans).returns(true)
    tenant.settings.allow_account_plans
    tenant.settings.update_column(:account_plans_ui_visible, true)
    assert account_plans_management_visible?

    stubs(:can?).with(:manage, :account_plans).returns(false)
    tenant.settings.allow_account_plans
    tenant.settings.update_column(:account_plans_ui_visible, true)
    refute account_plans_management_visible?

    stubs(:can?).with(:manage, :account_plans).returns(true)
    tenant.settings.deny_account_plans
    tenant.settings.update_column(:account_plans_ui_visible, true)
    refute account_plans_management_visible?

    stubs(:can?).with(:manage, :account_plans).returns(true)
    tenant.settings.allow_account_plans
    tenant.settings.update_column(:account_plans_ui_visible, false)
    refute account_plans_management_visible?
  end
end
