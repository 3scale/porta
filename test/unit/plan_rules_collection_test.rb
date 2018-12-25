# frozen_string_literal: true

require 'test_helper'

class PlanRulesCollectionTest < ActiveSupport::TestCase
  test '.find_for_plan' do
    plan = Plan.new(system_name: 'plan_with_plan_rule')
    plan_rule = PlanRule.new(system_name: plan.system_name, rank: 1)
    PlanRulesCollection.stubs(:plan_rules_by_name).returns({plan_rule.system_name => plan_rule})
    assert_equal plan_rule, PlanRulesCollection.find_for_plan(plan)

    plan = Plan.new(system_name: 'plan_without_plan_rule')
    assert_nil PlanRulesCollection.find_for_plan(plan)
  end

  test '.all_plan_rules_with_switches' do
    plan_rules = (3..5).to_a.map do |index|
      FactoryBot.build(:plan_rule, system_name: "planRule#{index}".to_sym, switches: Settings::SWITCHES[0..index])
    end

    response = PlanRulesCollection.all_plan_rules_with_switches

    plan_rules.each do |plan_rule|
      assert_not_nil(switches = response[plan_rule.system_name.to_s])
      assert_same_elements plan_rule.switches, switches
    end
  end

  test '.best_plan_rule?' do
    plan_rules = PlanRulesCollection.plan_rules_by_name.values
    best_plan_rule = plan_rules.pop

    assert PlanRulesCollection.best_plan_rule?(best_plan_rule)
    plan_rules.each { |plan_rule| refute PlanRulesCollection.best_plan_rule?(plan_rule) }
  end

  test '.can_upgrade? returns true if both plans have plan_rule with no metadata and the \'to\' has higher rank' do
    to, from = FactoryBot.create_list(:application_plan, 2)
    from.plan_rule.rank = 3
    to.plan_rule.rank = 4

    assert PlanRulesCollection.can_upgrade?(from: from, to: to)
  end

  test '.can_upgrade? returns true if the \'from\' argument does not have a plan_rule' do
    to = FactoryBot.create(:application_plan)
    from = Plan.new(system_name: 'plan_without_plan_rule')

    assert PlanRulesCollection.can_upgrade?(from: from, to: to)
  end

  test '.can_upgrade? returns false if the \'to\' argument does not have a plan_rule' do
    from = FactoryBot.create(:application_plan)
    to = Plan.new(system_name: 'plan_without_plan_rule')

    refute PlanRulesCollection.can_upgrade?(from: from, to: to)
  end

  test '.can_upgrade? returns false if the \'to\' argument is has a plan_rule with not_automatically_upgradable_to' do
    from, to = FactoryBot.create_list(:application_plan, 2)
    to.plan_rule.metadata = {cannot_automatically_be_upgraded_to: true}

    refute PlanRulesCollection.can_upgrade?(from: from, to: to)
  end

  test '.lowest_ranked_plan_with_switch returns the lowest published plan (by rank) that has the switch of the argument' do
    service = master_account.first_service!
    plan_types = %i[application_plan published_plan]

    plans = []
    (3..6).to_a.each do |number|
      2.times do |plan_type_index|
        plan = FactoryBot.create((plan_types[plan_type_index]), issuer: service)
        plan.plan_rule.switches = Settings::SWITCHES[0..number]
        plan.plan_rule.rank = number
        plans << plan
      end
    end

    assert_equal plans[5], PlanRulesCollection.lowest_ranked_plan_with_switch(Settings::SWITCHES[5])
  end
end
