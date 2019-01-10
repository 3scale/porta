require 'test_helper'

class Liquid::Drops::ContractDropTest < ActiveSupport::TestCase

  include Liquid

  def setup
    @contract = FactoryBot.build_stubbed(:contract)
    @drop = Drops::Contract.new(@contract)
  end

  def test_contract
    assert @drop.contract.is_a?(Liquid::Drops::Contract)
  end

  should 'returns id' do
    @contract.id = 42
    assert_equal @contract.id, @drop.id
  end

  should 'returns can_change_plan?' do
    @contract.stubs can_change_plan?: true
    assert @drop.can_change_plan?

    @contract.stubs can_change_plan?: false
    assert !@drop.can_change_plan?
  end

  should 'returns plan' do
    @contract.stubs plan: FactoryBot.build_stubbed(:account_plan)
    assert_kind_of Liquid::Drops::AccountPlan, @drop.plan

    @contract.stubs plan: FactoryBot.build_stubbed(:plan)
    assert_kind_of Liquid::Drops::Plan, @drop.plan
  end

  should 'returns plan_change_permission_name' do
    @contract.stubs plan_change_permission_name: 'foo bar'
    assert_equal 'foo bar', @drop.plan_change_permission_name
  end

  should 'returns plan_change_permission_warning' do
    @contract.stubs plan_change_permission_warning: 'foo bar'
    assert_equal 'foo bar', @drop.plan_change_permission_warning
  end
end
