# frozen_string_literal: true

FactoryBot.define do
  factory (:plan) do
    sequence(:name) { |n| "plan#{n}" }
    sequence(:system_name) {|n| "plan#{n}" }

    after(:stub) do |plan|
      plan.stubs(:features).returns([])
      plan.features.stubs(:find).with(:all, Mocha::ParameterMatchers::AnyParameters.new).returns([])
      plan.features.stubs(:visible).returns([])
    end
  end

  factory(:account_plan, :parent => :plan, :class => AccountPlan) do
    association(:issuer, :factory => :provider_account)
  end

  factory(:service_plan, :parent => :plan, :class => ServicePlan) do
    association(:issuer, :factory => :service)
  end

  factory(:application_plan, :parent => :plan, :class => ApplicationPlan) do
    association(:issuer, :factory => :service)

    after(:build) do |plan|
      plan_rule = PlanRulesCollection.find_for_plan(plan) || FactoryBot.build(:plan_rule, system_name: plan.system_name.to_sym)
      plan.stubs(:plan_rule).returns(plan_rule)
    end
  end

  factory(:published_plan, :parent => :application_plan) do
    after(:create) do |plan|
      plan.publish!
    end

    after(:stub) do |plan|
      plan.stubs(:state).returns('published')
    end
  end

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
