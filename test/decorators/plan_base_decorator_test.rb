# frozen_string_literal: true

require 'test_helper'

class PlanBaseDecoratorTest < Draper::TestCase
  setup do
    @plan = FactoryBot.create(:application_plan, issuer: FactoryBot.create(:service))
    @decorator = PlanBaseDecorator.new(plan)
  end

  attr_reader :plan, :decorator

  test '#index_table_actions for published plan' do
    plan.expects(:published?).returns(true).twice
    data = decorator.index_table_actions

    assert_not_includes data.pluck(:title), 'Publish'
    assert_includes data, { title: 'Hide', path: "/apiconfig/plans/#{plan.id}/hide", method: :post }
    assert_includes data, { title: 'Copy', path: "/apiconfig/plan_copies?plan_id=#{plan.id}", method: :post }
  end

  test '#index_table_actions for unpublished plan' do
    plan.expects(:published?).returns(false).twice
    data = decorator.index_table_actions
    actions = data.pluck(:title)

    assert_not_includes actions, 'Hide'
    assert_includes data, { title: 'Publish', path: "/apiconfig/plans/#{plan.id}/publish", method: :post }
    assert_includes data, { title: 'Copy', path: "/apiconfig/plan_copies?plan_id=#{plan.id}", method: :post }
  end

  test '#index_table_actions for destroyable plan' do
    plan.expects(:can_be_destroyed?).returns(true).once
    data = decorator.index_table_actions

    assert_includes data, { title: 'Delete', path: "/apiconfig/application_plans/#{plan.id}", method: :delete }
  end

  test '#index_table_actions for undestroyable plan' do
    plan.expects(:can_be_destroyed?).returns(false).once
    data = decorator.index_table_actions

    assert_not_includes data.pluck(:title), 'Delete'
  end
end
