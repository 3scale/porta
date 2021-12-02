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
end
