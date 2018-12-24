# frozen_string_literal: true

Factory.define(:plan) do |plan|
  plan.sequence(:name) { |n| "plan#{n}" }
  plan.sequence(:system_name) {|n| "plan#{n}" }

  plan.after_stub do |plan|
    plan.stubs(:features).returns([])
    plan.features.stubs(:find).with(:all, Mocha::ParameterMatchers::AnyParameters.new).returns([])
    plan.features.stubs(:visible).returns([])
  end
end

Factory.define(:account_plan, :parent => :plan, :class => AccountPlan) do |plan|
  plan.association(:issuer, :factory => :provider_account)
end

Factory.define(:service_plan, :parent => :plan, :class => ServicePlan) do |plan|
  plan.association(:issuer, :factory => :service)
end

Factory.define(:application_plan, :parent => :plan, :class => ApplicationPlan) do |plan|
  plan.association(:issuer, :factory => :service)

  plan.after_build do |plan|
    plan_rule = PlanRulesCollection.find_for_plan(plan) || FactoryBot.build(:plan_rule, system_name: plan.system_name.to_sym)
    plan.stubs(:plan_rule).returns(plan_rule)
  end
end

Factory.define(:published_plan, :parent => :application_plan) do |plan|
  plan.after_create do |plan|
    plan.publish!
  end

  plan.after_stub do |plan|
    plan.stubs(:state).returns('published')
  end
end

FactoryBot.define do
  factory :plan_rule do
    initialize_with do
      plan_rule = PlanRule.new(system_name: :example, switches: [], limits: {max_users: nil, max_services: nil}, rank: 0, metadata: {})

      collection = PlanRulesCollection.plan_rules_by_name
      PlanRulesCollection.stubs(:plan_rules_by_name)
        .returns(collection.merge({plan_rule.system_name => plan_rule}))

      %w[switches metadata limits rank].each do |attr_name|
        plan_rule.define_singleton_method("#{attr_name}=".to_sym) { |*args| instance_variable_set("@#{attr_name}".to_sym, *args) }
      end

      plan_rule.define_singleton_method(:system_name=) do |new_system_name|
        PlanRulesCollection.stubs(:plan_rules_by_name)
          .returns(
            collection.reject { |key, _| key == system_name.to_sym }.merge({new_system_name.to_sym => plan_rule})
          )
        instance_variable_set(:@system_name, new_system_name.to_sym)
      end

      plan_rule
    end
  end
end
