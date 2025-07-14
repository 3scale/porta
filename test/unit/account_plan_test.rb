# frozen_string_literal: true

require 'test_helper'

class AccountPlanTest < ActiveSupport::TestCase
  def setup
    @plan = FactoryBot.create(:simple_account_plan)
  end

  class CustomPlanTest < AccountPlanTest
    def setup
      super
      @custom_plan = @plan.customize
    end

    test 'destroy custom account plans if its single buyer is destroyed' do
      buyer = FactoryBot.create(:simple_buyer)
      buyer.buy!(@custom_plan)
      buyer.destroy
      assert buyer.destroyed?
      assert_raise ActiveRecord::RecordNotFound do
        @custom_plan.reload
      end
    end
  end

  test 'destroy plan does not update position when the account is scheduled for deletion' do
    account = @plan.issuer
    new_plan = FactoryBot.create(:simple_account_plan, issuer: account, position: 1)
    plans = account.account_plans.order(position: :asc).to_a
    assert_equal new_plan, plans.first
    account.schedule_for_deletion!

    assert_no_change of: -> { plans.last.reload.position } do
      new_plan.destroy!
    end
  end

  test 'destroy plan does not update position when the account is deteted' do
    account = @plan.issuer
    new_plan = FactoryBot.create(:simple_account_plan, issuer: account, position: 1)
    plans = account.account_plans.order(position: :asc).to_a
    assert_equal new_plan, plans.first
    account.delete

    assert_no_change of: -> { plans.last.reload.position } do
      new_plan.destroy!
    end
  end
end
