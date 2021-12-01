# frozen_string_literal: true

require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  fixtures :countries

  subject { FactoryBot.build_stubbed(:simple_plan) }

  should validate_presence_of :name
  should validate_numericality_of :setup_fee
  should validate_numericality_of :cost_per_month

  should belong_to :issuer
  should have_many(:cinstances).dependent(:destroy)
  should have_many(:customizations).dependent(:destroy)

  should belong_to :original

  should allow_value(:sum).for(:cost_aggregation_rule)
  should allow_value(:min).for(:cost_aggregation_rule)
  should allow_value(:max).for(:cost_aggregation_rule)
  should_not allow_value(:avg).for(:cost_aggregation_rule)
  should_not allow_value(:zero).for(:cost_aggregation_rule)
  should_not allow_value('').for(:cost_aggregation_rule)
  should_not allow_value(nil).for(:cost_aggregation_rule)

  def setup
    @plan = FactoryBot.create(:simple_plan, issuer_id: 42, issuer_type: 'Plan', type: 'Plan')
  end

  attr_reader :plan

  test 'Plan.stock returns only stock plans' do
    custom_plan = plan.customize.save!

    assert_contains         Plan.stock, plan
    assert_does_not_contain Plan.stock, custom_plan
  end

  test 'nil values' do
    assert_valid plan

    plan.setup_fee = nil

    assert_not plan.valid?
    assert plan.errors[:setup_fee].present?
  end

  test 'default values' do
    assert_equal 0.0, plan.setup_fee
    assert_equal 0.0, plan.cost_per_month
  end

  test 'a customized plan should be of the same class as the original' do
    %w[application_plan account_plan service_plan].each do |plan_type|
      stock = FactoryBot.create("simple_#{plan_type}".to_sym)
      stock.customize.save!
      assert(stock.customizations.all? { |custom| stock.instance_of?(custom.class) })
    end
  end

  test "a customized plan features should be the same as of the original plan type" do
    %w[application_plan account_plan service_plan].each do |plan_type|
      stock = FactoryBot.create("simple_#{plan_type}".to_sym)
      enabled = stock.issuer.features.create!(name: "feature enabled", scope: plan_type.camelize)

      stock.features_plans.create!(feature: enabled)
      assert_equal stock.features.reload, [enabled]
      stock.customize.save!

      assert(stock.customizations.all? { |custom| stock.features == custom.features })
    end
  end

  test "copy a plan should create identical copy of plan with (copy) suffix in name" do
    %w[account_plan service_plan].each do |plan_type|
      stock = FactoryBot.create("simple_#{plan_type}".to_sym)
      feature = stock.issuer.features.create!(name: "#{plan_type} feature enabled", scope: plan_type.camelize)
      stock.features_plans.create!(feature: feature)

      clone = stock.copy
      clone.save!

      the_different = %w[name system_name id position created_at updated_at updated_at]
      the_same = stock.attribute_names - the_different

      assert_equal stock.attributes.slice(*the_same), clone.attributes.slice(*the_same)
      assert_equal stock.features, clone.features

      assert_equal "#{stock.name} (copy)", clone.name
      assert_not_equal stock.system_name, clone.system_name, "System name of the cloned plan should be different"
    end
  end

  test '#provided_by' do
    plan = FactoryBot.create(:application_plan)
    provider = plan.provider_account

    assert_same_elements [
      provider.services.map(&:service_plans),
      provider.services.map(&:application_plans),
      provider.account_plans
    ].flatten, Plan.provided_by(provider)
  end
end
