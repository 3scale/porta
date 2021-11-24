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

  def test_contracts_count_normal_behavior
    account = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:service, account: account)
    plan = FactoryBot.create(:application_plan, service: service)

    assert_equal 0, plan.reload.contracts_count
    app = FactoryBot.create(:cinstance, service: service, plan: plan)
    assert_equal 1, plan.reload.contracts_count

    app.destroy!
    assert_equal 0, plan.reload.contracts_count
  end

  def test_contracts_count_account_being_deleted
    account = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:service, account: account)
    plan = FactoryBot.create(:application_plan, service: service)

    assert_equal 0, plan.reload.contracts_count
    app = FactoryBot.create(:cinstance, service: service, plan: plan)
    assert_equal 1, plan.reload.contracts_count

    account.schedule_for_deletion!
    app.destroy!
    assert_equal 1, plan.reload.contracts_count
  end

  def test_contracts_count_service_being_deleted
    account = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:service, account: account)
    plan = FactoryBot.create(:application_plan, service: service, issuer: service)

    assert_equal 0, plan.reload.contracts_count
    app = FactoryBot.create(:cinstance, service: service, plan: plan)
    assert_equal 1, plan.reload.contracts_count

    service.stubs(last_accessible?: false)
    service.mark_as_deleted!
    app.destroy!
    assert_equal 1, plan.reload.contracts_count
  end

  def test_reset_contracts_counter
    assert FactoryBot.create(:simple_application_plan).reset_contracts_counter
  end

  test '#destroy does not lock if cannot be destroyed' do
    plan_one = FactoryBot.create(:application_plan)
    plan_one.expects(:can_be_destroyed?).returns(false)
    plan_one.expects(:lock!).never
    assert_not plan_one.destroy
  end

  test 'published returns only published plans' do
    plan_one = FactoryBot.create(:simple_application_plan)
    plan_one.publish!

    plan_two = FactoryBot.create(:simple_application_plan)

    assert_contains         Plan.published, plan_one
    assert_does_not_contain Plan.published, plan_two
  end

  test 'Plan.stock returns only stock plans' do
    stock_plan = FactoryBot.create(:simple_application_plan)
    custom_plan = stock_plan.customize.save!

    assert_contains         Plan.stock, stock_plan
    assert_does_not_contain Plan.stock, custom_plan
  end

  test 'published plan is not losing master status when hidden' do
    service = FactoryBot.create(:simple_service)
    plan = FactoryBot.create(:simple_application_plan, :issuer => service)
    plan.publish!
    service.application_plans.default = plan

    plan.hide!
    plan.reload
    assert_equal true, plan.hidden?
    assert_equal plan, service.application_plans.default
  end

  test 'destroy custom account plans if its single buyer is destroyed' do
    custom_account_plan = FactoryBot.create(:simple_application_plan).customize
    buyer = FactoryBot.create(:simple_buyer)
    buyer.buy! custom_account_plan
    buyer.destroy
    assert buyer.destroyed?
    assert_raise ActiveRecord::RecordNotFound do
      custom_account_plan.reload
    end
  end

  test 'destroy custom service plans if its single buyer is destroyed' do
    custom_service_plan = FactoryBot.create(:simple_service_plan).customize
    buyer = FactoryBot.create(:simple_buyer)
    buyer.buy! custom_service_plan
    buyer.destroy
    assert buyer.destroyed?
    assert_raise ActiveRecord::RecordNotFound do
      custom_service_plan.reload
    end
  end

  test 'nil values' do
    plan = FactoryBot.create(:simple_plan, issuer_id: 42, issuer_type: 'Plan', type: 'Plan')
    assert plan.valid?

    plan.setup_fee = nil

    assert_not plan.valid?
    assert plan.errors[:setup_fee].present?
  end

  test 'default values' do
    plan = Plan.new

    assert_equal 0.0, plan.setup_fee
    assert_equal 0.0, plan.cost_per_month
  end

  test 'a published plan should transition to hidden state on :hide!' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.publish!
    plan.hide!
    assert plan.hidden?
  end

  test 'a published plan should return plan that is not published on customize' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.publish!
    custom_plan = plan.customize
    custom_plan.save!

    assert_not custom_plan.published?
  end

  test 'a plan should transition to published state on :publish!' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.publish!
    assert plan.published?
  end

  test 'a plan should return false on customized?' do
    plan = FactoryBot.create(:simple_application_plan)
    assert_not plan.customized?
  end

  test 'a plan should return name on original_name' do
    plan = FactoryBot.create(:simple_application_plan)
    assert_equal plan.name, plan.original_name
  end

  test 'a plan should not fail with usage_limits validating presence of plan' do
    plan = FactoryBot.create(:simple_application_plan)
    FactoryBot.create(:usage_limit, plan: plan)

    custom = plan.customize
    custom.save

    assert_not_equal custom.id, nil
  end

  test 'a customized plan should be saved' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.stubs(:randomized).returns(1)
    customized_plan = plan.customize

    assert_not customized_plan.new_record?
    assert_not_equal plan, customized_plan
  end

  test "a customized plan should generate randomized system_names to avoid clashes customizing several times" do
    plan = FactoryBot.create(:simple_application_plan)
    plan.stubs(:randomized).returns(1)
    customized_plan = plan.customize
    assert_equal "#{plan.system_name}_custom_1", customized_plan.system_name

    plan.stubs(:randomized).returns(2)
    second_custom_plan = plan.customize
    assert_not second_custom_plan.new_record? # even make sure the custom plan is saved
    assert second_custom_plan.customized?
    assert_equal "#{plan.system_name}_custom_2", second_custom_plan.system_name
  end

  test 'a customized plan should be assigned to the same service as original plan' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.stubs(:randomized).returns(1)
    customized_plan = plan.customize
    assert_equal plan.service, customized_plan.service
  end

  test 'a customized plan should return true on customized?' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.stubs(:randomized).returns(1)
    customized_plan = plan.customize
    assert customized_plan.customized?
  end

  test 'a customized plan should  be assigned to original plan' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.stubs(:randomized).returns(1)
    customized_plan = plan.customize
    assert_equal plan, customized_plan.original
  end

  test 'a customized plan should append (custom) original plan name' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.stubs(:randomized).returns(1)
    customized_plan = plan.customize
    assert_equal "#{customized_plan.original.name} (custom)", customized_plan.name
  end

  test 'a customized plan should return name of original plan on original_name' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.stubs(:randomized).returns(1)
    customized_plan = plan.customize
    assert_equal plan.name, customized_plan.original_name
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
      enabled = stock.issuer.features.create!(:name => "feature enabled",
                                              :scope => plan_type.camelize)

      stock.features_plans.create! :feature => enabled
      assert_equal stock.features.reload, [enabled]
      stock.customize.save!

      assert(stock.customizations.all? { |custom| stock.features == custom.features })
    end
  end

  test "copy a plan should create identical copy of plan with (copy) suffix in name" do
    %w[account_plan service_plan].each do |plan_type|
      stock = FactoryBot.create("simple_#{plan_type}".to_sym)
      feature = stock.issuer.features.create!(:name => "#{plan_type} feature enabled",
                                              :scope => plan_type.camelize)
      stock.features_plans.create! :feature => feature

      clone = stock.copy
      clone.save!

      the_different = %w[name system_name id position created_at updated_at updated_at]
      the_same = stock.attribute_names - the_different

      assert_equal stock.attributes.slice(*the_same), clone.attributes.slice(*the_same)
      assert_equal stock.features, clone.features

      assert_equal "#{stock.name} (copy)", clone.name
      assert stock.system_name != clone.system_name, "System name of the cloned plan should be different"
    end
  end

  test "copy a plan should generate randomized system_names to avoid clashes" do
    plan = FactoryBot.build_stubbed(:simple_application_plan, system_name: 'somee_plan_foo')
    plan.stubs(:randomized).returns(1)
    copy1 = plan.copy
    assert_equal "#{plan.system_name}_copy_1", copy1.system_name
    copy1.save!

    plan.stubs(:randomized).returns(2)
    copy2 = plan.copy
    assert_equal "#{plan.system_name}_copy_2", copy2.system_name
  end

  test "copy a plan should create identical copy of application plan with associations" do
    stock = FactoryBot.create(:simple_application_plan)
    feature = stock.issuer.features.create!(:name => "feature enabled",
                                            :scope => 'ApplicationPlan')
    stock.features_plans.create! :feature => feature
    metric = FactoryBot.create(:metric, :service => stock.service, :system_name => 'frags')
    stock.pricing_rules.create! :metric => metric, :min => 1, :max => 5, :cost_per_unit => 1
    ul1 = stock.usage_limits.new :period => :day, :value => 10
    ul1.metric = metric
    ul1.save!
    ul2 = stock.usage_limits.new :period => :week, :value => 50
    ul2.metric = metric
    ul2.save!

    stock.save!

    clone = stock.reload.copy
    clone.save!
    clone.reload

    attrs = stock.attribute_names - %w[name system_name id position created_at updated_at]
    assert_equal stock.attributes.slice(*attrs), clone.attributes.slice(*attrs)

    assert_equal stock.features, clone.features
    assert_equal stock.metrics,  clone.metrics

    assert_equal stock.usage_limits.count,  clone.usage_limits.count
    assert_equal stock.pricing_rules.count, clone.pricing_rules.count
  end

  test "copy a plan should create a copy even if original's plan system_name has about 220 characters" do
    # real system_name from one of our customers
    plan = FactoryBot.create(:application_plan, system_name:
      '99_mo_15kPerson_5kCompany_006Overage_copy_1427860479286288_copy_1427' \
      '8611021696677_copy_14404293909783192_copy_1443476994469875_copy_1443' \
      '5533977474842_copy_1443819978875712_copy_14460495243248389')
    copy = plan.copy

    copy.save

    assert_equal true, copy.valid?
    assert copy.errors[:system_name].blank?
  end

  # this is bug in aasm plugin - replace it with state_machine gem
  test "clone state" do
    stock = FactoryBot.build_stubbed(:simple_application_plan, state: 'published', system_name: 'application_plan')

    clone = stock.copy
    clone.save!
    clone.reload

    assert_equal stock.state, clone.state
  end

  test 'a plan on :aggregate_costs should return sum of costs when cost_aggregation_rule is :sum' do
    costs = [100, 200, 300]
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_aggregation_rule = :sum
    assert_equal 600, plan.aggregate_costs(costs)
  end

  test 'a plan on :aggregate_costs should return maximum of costs when cost_aggregation_rule is :max' do
    costs = [100, 200, 300]
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_aggregation_rule = :max
    assert_equal 300, plan.aggregate_costs(costs)
  end

  test 'a plan on :aggregate_costs should return minimum of costs when cost_aggregation_rule is :min' do
    costs = [100, 200, 300]
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_aggregation_rule = :min
    assert_equal 100, plan.aggregate_costs(costs)
  end

  test 'a plan on :aggregate_costs should return money' do
    costs = [100, 200, 300]
    plan = FactoryBot.create(:simple_application_plan)
    aggregated_cost = plan.aggregate_costs(costs)
    assert_respond_to aggregated_cost, :amount
    assert_respond_to aggregated_cost, :currency

    aggregated_cost = plan.aggregate_costs([])
    assert_respond_to aggregated_cost, :amount
    assert_respond_to aggregated_cost, :currency
  end

  test 'a plan should set cancellation period using :cancellation_period_in_days' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cancellation_period_in_days = 2
    assert_equal 2.days, plan.cancellation_period
  end

  test 'a plan on :free? should return true if there are no pricing rules' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_per_month = 0
    assert plan.free?
  end

  test 'a plan on :free? should return true if there is no setup fee' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_per_month = 0
    plan.setup_fee = 0
    assert plan.free?
  end

  test 'a plan on :free? should return false if there are some pricing rules' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_per_month = 0
    plan.pricing_rules.build(max: 100, cost_per_unit: 0.1)
    assert_not plan.free?
  end

  test 'a plan on :free? should return false if there is a setup fee' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_per_month = 0
    plan.setup_fee = 10
    assert_not plan.free?
  end

  test 'a plan on :free? return true if cost_per_month is any kind od zero' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_per_month = 0
    plan.cost_per_month = 0
    assert plan.free?

    plan.cost_per_month = 0.0
    assert plan.free?

    plan.cost_per_month = BigDecimal('0.0')
    assert plan.free?
  end

  test 'a plan on :free? return false if cost_per_month is greater than zero' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cost_per_month = 0
    plan.cost_per_month = 100
    assert_not plan.free?
  end

  test 'a plan accept string for cancellation_period_in_days' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cancellation_period_in_days = '4'
    assert_equal 4.days, plan.cancellation_period
  end

  test 'a plan should return Money on :cost_per_month' do
    plan = FactoryBot.create(:simple_application_plan)
    assert_instance_of ThreeScale::Money, plan.cost_per_month
  end

  test 'a plan on :bought_by? should return true if there is cinstance for given user account' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cinstances.delete_all
    buyer = FactoryBot.create(:simple_buyer)
    buyer.buy!(plan)
    assert plan.bought_by?(buyer)
  end

  test 'a plan on :bought_by? should return false if there are only deleted cinstance for given user account' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cinstances.delete_all
    buyer = FactoryBot.create(:simple_buyer)
    cinstance = buyer.buy!(plan)
    cinstance.destroy

    assert_not plan.bought_by?(buyer)
  end

  test 'a plan on :bought_by? should return false for nil' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.cinstances.delete_all
    assert_not plan.bought_by?(nil)
  end

  test 'a plan with fixed cost should return correct values on cost_for_period' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.update(cost_per_month: 100)
    assert_equal 100, plan.cost_for_period(Time.utc(2009, 6, 1)..Time.utc(2009, 6, 1).end_of_month)

    assert_equal 50, plan.cost_for_period(Time.utc(2009, 6, 16)..Time.utc(2009, 6, 1).end_of_month)
    cost = plan.cost_for_period(Time.utc(2009, 6, 30)..Time.utc(2009, 6, 30).end_of_day)

    assert_in_delta 3.3, cost, 0.1
  end

  test 'a plan with fixed cost should round to 2 decimals' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.update(cost_per_month: 100)
    assert_equal 66.67, plan.cost_for_period(Time.utc(2009, 6, 11)..Time.utc(2009, 6, 1).end_of_month)
  end

  test 'a plan with fixed cost should return 0.0 if cost_per_month is zero despite of period range' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.update(cost_per_month: 0)
    date = Time.utc(2018, 4, 1)

    period = date..date.end_of_month
    assert_equal 0, plan.cost_for_period(period)

    period = date..(date + 1.month).end_of_month
    assert_equal 0, plan.cost_for_period(period)
  end

  test 'new plan is created in hidden state' do
    plan = FactoryBot.create(:simple_service).application_plans.build(:name => 'name')
    plan.save!

    assert_equal 'hidden', plan.state
  end

  test "destroying a plan should not be possible if has contract" do
    plan = FactoryBot.create(:simple_application_plan)
    cinstance = FactoryBot.create(:simple_cinstance, :plan => plan)

    plan.reload
    plan.destroy

    assert Cinstance.find_by(id: cinstance.id)
    assert_not plan.reload.nil?
  end

  test "destroying a plan should not be possible if any of it's customization has contract" do
    plan = FactoryBot.create(:simple_application_plan)
    cinstance = FactoryBot.create(:simple_cinstance, :plan => plan)

    cinstance.customize_plan!

    plan.reload
    plan.destroy

    assert Cinstance.find_by(id: cinstance.id)
    assert_not plan.destroyed?
  end

  test "destroying a plan should not destroy application in backend when plan cannot be destroyed" do
    plan = FactoryBot.create(:simple_application_plan)
    FactoryBot.create(:simple_cinstance, :plan => plan)

    assert_not plan.can_be_destroyed?

    ThreeScale::Core::Application.expects(:delete).never
    # I don't know why this does not do the trick
    # cinstance.expects(:delete_backend_application).never
    plan.destroy
  end

  test "destroying a plan should destroy it's usage limits" do
    plan = FactoryBot.create(:simple_application_plan)
    usage_limit = FactoryBot.create(:usage_limit, :plan => plan)

    plan.destroy

    assert_nil UsageLimit.find_by(id: usage_limit.id)
  end

  test "destroying a plan should destroy it's pricing rules" do
    plan = FactoryBot.create(:simple_application_plan)
    pricing_rule = FactoryBot.create(:pricing_rule, :plan => plan)

    plan.destroy

    assert_nil PricingRule.find_by(id: pricing_rule.id)
  end

  # Regression tests for https://github.com/3scale/system/issues/2521
  #
  test "don't raise exception when setup_fee is nil" do
    plan = FactoryBot.build_stubbed(:application_plan)
    plan.setup_fee = nil
    plan.valid?
  end

  test "don't raise exception when cost_per_month is nil" do
    plan = FactoryBot.build_stubbed(:application_plan)
    plan.cost_per_month = nil
    plan.valid?
  end

  test 'setup_fee cannot be negative' do
    plan = FactoryBot.build_stubbed(:application_plan)
    plan.setup_fee = -10.00
    assert_not plan.valid?
    assert_equal ['must be greater than or equal to 0.0'], plan.errors[:setup_fee]
    plan.setup_fee = 15.00
    assert plan.valid?
  end

  test 'cost_per_month cannot be negative' do
    plan = FactoryBot.build_stubbed(:application_plan)
    plan.cost_per_month = -10.00
    assert_not plan.valid?
    assert_equal ['must be greater than or equal to 0.0'], plan.errors[:cost_per_month]
    plan.cost_per_month = 15.00
    assert plan.valid?
  end

  test 'trial_period_days cannot be negative' do
    plan = FactoryBot.build_stubbed(:application_plan)
    plan.trial_period_days = -1
    assert_not plan.valid?
    assert_equal ['must be greater than or equal to 0'], plan.errors[:trial_period_days]
    plan.trial_period_days = 10
    assert plan.valid?
  end

  test 'let global finance setting prevail' do
    plan = FactoryBot.create(:simple_application_plan)
    plan.provider_account.billing_strategy = Finance::BillingStrategy.new

    assert plan.pricing_enabled?

    ThreeScale.config.stubs(onpremises: true)
    plan.provider_account.stubs(master?: true)
    assert_not plan.pricing_enabled?
  end

  def test_plan_not_locked_if_deleted_from_db
    plan = FactoryBot.create(:simple_application_plan)
    plan.class.expects(:exists?).with(plan.id).at_least_once.returns(false)
    plan.expects(:lock!).never
    plan.destroy
  end

  def test_plan_not_audited_if_deleted_from_db
    plan = FactoryBot.create(:simple_application_plan)
    plan.class.expects(:exists?).with(plan.id).at_least_once.returns(false)
    plan.expects(:audit_destroy).never
    plan.destroy
  end

  def test_provided_by
    plan = FactoryBot.create(:application_plan)
    provider = plan.provider_account

    assert_same_elements [
      provider.services.map(&:service_plans),
      provider.services.map(&:application_plans),
      provider.account_plans
    ].flatten, Plan.provided_by(provider)
  end
end

class CustomizedPlanTest < ActiveSupport::TestCase
  def setup
    @stock = FactoryBot.create(:simple_application_plan)
    @custom = @stock.customize
    @custom.save!
  end

  test 'Plan.customized should return only customized plans' do
    assert_contains         Plan.customized, @custom
    assert_does_not_contain Plan.customized, @stock
  end

  test 'contain plan customizations' do
    assert @stock.customizations.to_s, [@custom].to_s
  end
end
