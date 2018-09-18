require 'test_helper'
class Liquid::Drops::PlanDropTest < ActiveSupport::TestCase
  include Liquid
  include Liquid::StandardFilters

  def setup
    @plan = FactoryGirl.create(:account_plan, cost_per_month: 2)
    @drop = Drops::Plan.new(@plan)
  end

  def test_setup_fee
    @plan.setup_fee = 42.24

    @plan.save

    assert_match(/42.24/, @drop.setup_fee)
  end

  def test_sort_by_flat_cost
    plan_2 = FactoryGirl.create(:account_plan, cost_per_month: 1)
    drop_2 = Drops::Plan.new(plan_2)

    sorted_plan_ids = sort([@drop, drop_2], :flat_cost).map(&:id)

    assert_equal [drop_2.id, @drop.id], sorted_plan_ids
  end

  def test_sort_by_flat_cost_with_cost_per_month_zero
    plan_2 = FactoryGirl.create(:account_plan, cost_per_month: 0)
    drop_2 = Drops::Plan.new(plan_2)

    sorted_plan_ids = sort([@drop, drop_2], :flat_cost).map(&:id)

    assert_equal [@drop.id, plan_2.id], sorted_plan_ids
  end

  def test_sort_by_cost
    plan_2 = FactoryGirl.create(:account_plan, cost_per_month: 0)
    drop_2 = Drops::Plan.new(plan_2)

    sorted_plan_ids = sort([@drop, drop_2], :cost).map(&:id)

    assert_equal [plan_2.id, @drop.id], sorted_plan_ids
  end

  def test_trial_period_days
    plan = Plan.new(trial_period_days: 7)
    drop = Drops::Plan.new(plan)

    assert_equal 7, drop.trial_period_days
  end
end
