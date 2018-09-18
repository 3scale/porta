require 'test_helper'

class Liquid::Drops::PlanChangeTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @contract = Contract.new(name: 'Awesome app')
    @contract.stubs(id: 'contract_id')
    @plan = Plan.new(name: 'Free plan')
    @plan.stubs(id: 'current_plan_id')
    @new_plan = Plan.new(name: 'Paid plan')
    @new_plan.stubs(id: 'new_plan_id')
    @contract.plan = @plan
    @drop = Drops::PlanChange.new(@contract, @new_plan)
  end

  test '#contract' do
    assert_equal Drops::Application.new(@contract), @drop.contract
  end

  test '#previous_plan' do
    assert_equal Drops::ApplicationPlan.new(@plan), @drop.previous_plan
  end

  test '#plan' do
    assert_equal Drops::ApplicationPlan.new(@new_plan), @drop.plan
  end

  test '#confirm_path' do
    assert_equal '/admin/contracts/contract_id?plan_id=new_plan_id', @drop.confirm_path
  end

  test '#cancel_path' do
    assert_equal '/admin/account/plan_changes/contract_id', @drop.cancel_path
  end
end
