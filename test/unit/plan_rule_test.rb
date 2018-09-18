# frozen_string_literal: true

require 'test_helper'

class PlanRuleTest < ActiveSupport::TestCase
  test '#trial?' do
    plan_rule = PlanRule.new(system_name: :plan_rule, rank: 0, metadata: {trial: true})
    assert plan_rule.trial?

    plan_rule = PlanRule.new(system_name: :plan_rule, rank: 0, metadata: {})
    refute plan_rule.trial?
  end

  test '#not_automatically_upgradable_to?' do
    plan_rule = PlanRule.new(system_name: :plan_rule, rank: 0, metadata: {cannot_automatically_be_upgraded_to: true})
    assert plan_rule.not_automatically_upgradable_to?

    plan_rule = PlanRule.new(system_name: :plan_rule, rank: 0, metadata: {})
    refute plan_rule.not_automatically_upgradable_to?
  end

  test '#best_plan?' do
    plan_rule = PlanRule.new(system_name: :plan_rule, rank: 0)
    PlanRulesCollection.expects(:best_plan_rule?).with(plan_rule)
    plan_rule.best_plan?
  end
end
