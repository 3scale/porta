# frozen_string_literal: true

module PlanRulesCollection
  class PlanRulesNotLoaded < StandardError; end

  module_function

  PLAN_RULES_BY_NAME = PlanRuleLoader.load_config

  def find_for_plan(plan)
    plan_rules_by_name[plan.system_name.to_sym]
  end

  def all_plan_rules_with_switches
    plan_rules_by_name.each_with_object({}) { |(system_name, plan_rule), response_hash| response_hash[system_name.to_s] = plan_rule.switches }
  end

  def best_plan_rule?(plan_rule)
    plan_rule == plan_rules_by_name.values.last
  end

  def can_upgrade?(from:, to:)
    return false unless (to_plan_rule = find_for_plan(to))
    return false if to_plan_rule.not_automatically_upgradable_to?

    from_plan_rule = find_for_plan(from)
    !from_plan_rule || (from_plan_rule.rank < to_plan_rule.rank)
  end

  def lowest_ranked_plan_with_switch(switch)
    plan = nil
    plan_rules_by_name.find do |system_name, plan_rule|
      plan_rule.switches.include?(switch.to_sym) && (plan = Account.master.application_plans.published.find_by_system_name(system_name))
    end
    plan
  end

  def plan_rules_by_name
    PLAN_RULES_BY_NAME
  end
end
