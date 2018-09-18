# frozen_string_literal: true

require 'test_helper'

class PlanRuleLoaderTest < ActiveSupport::TestCase
  def given_plan_rules_config(config)
    ThreeScale.config.stubs(:plan_rules).returns(config)
  end

  class LoadErrorTest < PlanRuleLoaderTest
    test 'raises error when a rank is not an integer' do
      config = {'enterprise' => {'rank' => nil}}
      given_plan_rules_config(config) do
        assert_raises(TypeError) { PlanRuleLoader.load_config }
      end
    end
  end

  class LoadCorrectAndDefaultRuleTest < PlanRuleLoaderTest
    setup do
      @expected_default = PlanRuleLoader::DEFAULT_RULES.each_with_object({}) do |(key, attributes), collection|
        system_name = key.to_sym
        collection[system_name] = PlanRule.new(system_name: system_name, **attributes.deep_symbolize_keys)
      end
    end

    test 'default when no yaml' do
      given_plan_rules_config({})
      PlanRuleLoader.load_config.each do |system_name, plan_rule|
        assert_instance_of PlanRule, plan_rule
        assert_equal plan_rule, @expected_default[system_name]
      end
    end

    test 'load correct and default merged when there is yaml and no enterprise' do
      config = {'middle' => {'rank' => 2}, 'simple' => {'rank' => 1}, 'better' => {'rank' => 3}}
      given_plan_rules_config(config)
      collection = PlanRuleLoader.load_config
      assert %i[simple middle better enterprise], collection.keys
      collection.each_value { |plan_rule| assert_instance_of PlanRule, plan_rule }

      assert_equal @expected_default.values.last.rank, collection.values.last.rank
    end

    test 'load correct and default not merged when there is yaml with enterprise' do
      config = {'enterprise' => {'rank' => 200}, 'simple' => {'rank' => 1}, 'better' => {'rank' => 3}}
      given_plan_rules_config(config)
      collection = PlanRuleLoader.load_config
      assert %i[simple middle better enterprise], collection.keys
      collection.each_value { |plan_rule| assert_instance_of PlanRule, plan_rule }

      assert_equal 200, collection.values.last.rank
    end
  end
end
