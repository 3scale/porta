require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PricingRuleTest < ActiveSupport::TestCase
  def setup
    @plan = Factory(:application_plan)
  end

  should have_db_column(:min).with_options(:default => 1)
  should_not allow_value(0).for(:min).with_message(/must be greater than or equal to 1/)
  should_not allow_value(-1).for(:min).with_message(/must be greater than or equal to 1/)

  should 'have sufficient precision for cost_per_unit' do
    rule = @plan.pricing_rules.create!(:cost_per_unit => 0.0001, :min => 1, :max => 2)
    rule.reload

    assert_equal 0.0001, rule.cost_per_unit
  end

  should "prohibit a nil cost_per_unit" do
    rule = @plan.pricing_rules.new(:min => 1, :max => 10, :cost_per_unit => nil)
    assert !rule.valid?
    assert_not_nil rule.errors[:cost_per_unit].presence
  end

  should "prohibit a nil min" do
    rule = @plan.pricing_rules.new(:min => '', :max => 10, :cost_per_unit => 4)
    rule.valid?
    assert_not_nil rule.errors[:min].presence

    rule = @plan.pricing_rules.new(:min => 1, :max => 10, :cost_per_unit => 4)
    assert rule.errors.empty?
  end

  should "prohibit range overlap (min value less than previous max values)" do
     @plan.pricing_rules.create!(:min => 1, :max => 10, :cost_per_unit => 4)

     rule = @plan.pricing_rules.new(:min => 1, :max => 10, :cost_per_unit => 4)
     rule.valid?
     assert_not_nil rule.errors[:min].presence

     rule = @plan.pricing_rules.new(:min => 10, :max => 12, :cost_per_unit => 4)
     rule.valid?
     assert_not_nil rule.errors[:min].presence

     rule = @plan.pricing_rules.create!(:min => 11, :max => 12, :cost_per_unit => 4)
     assert rule.errors.empty?
  end

  should "prohibit overlap for infinity max values" do
    @plan.pricing_rules.create!(:min => 1, :max => nil, :cost_per_unit => 4)

    rule = @plan.pricing_rules.new(:min => 10, :max => 12, :cost_per_unit => 4)
    rule.valid?
    assert_not_nil rule.errors[:min].presence
  end

  should "prohibit overlap when creating a new rule with infinity max values" do
    @plan.pricing_rules.create!(:min => 1, :max => 12, :cost_per_unit => 4)

    rule = @plan.pricing_rules.new(:min => 10, :max => nil, :cost_per_unit => 4)
    rule.valid?
    assert_not_nil rule.errors[:min].presence
  end

  should "prohibit max value less than min value" do
     rule = @plan.pricing_rules.new(:min => 10, :max => 1, :cost_per_unit => 4)
     rule.valid?
     assert_not_nil rule.errors[:max].presence
  end

  should "allow max value to be equal to min value and return correct cost" do
     rule = @plan.pricing_rules.new(:min => 10, :max => 10, :cost_per_unit => 4)
     rule.valid?
     assert_nil rule.errors[:max].presence
     assert_equal 4, rule.cost_for_value(10)
  end

  should 'allow range overlap for pricing rules with different metrics' do
    metric_one = Factory(:metric, :service => @plan.service)
    metric_two = Factory(:metric, :service => @plan.service)

    rule_one = @plan.pricing_rules.create!(:metric => metric_one, :min => 1, :max => 10,
                                           :cost_per_unit => 0.2)
    rule_two = @plan.pricing_rules.build(:metric => metric_two, :min => 5, :max => 22,
                                         :cost_per_unit => 0.3)

    assert rule_two.valid?
  end

  should 'allow to be updated' do
    rule = @plan.pricing_rules.create!(:min => 16, :max => 100, :cost_per_unit => 0.2)
    rule.update_attributes(:min => 12)

    assert rule.valid?
  end

  should 'return correct cost for value on single instance' do
    rule = @plan.pricing_rules.new(:min => 1, :max => 10, :cost_per_unit => 4)
    assert_equal 0, rule.cost_for_value(0)
    assert_equal 4, rule.cost_for_value(1)
    assert_equal 40, rule.cost_for_value(10)
    assert_equal 40, rule.cost_for_value(11)
    assert_equal 40, rule.cost_for_value(1_000_000_000)

    rule = @plan.pricing_rules.new(:min => 11, :max => 20, :cost_per_unit => 3)
    assert_equal 0, rule.cost_for_value(0)
    assert_equal 0, rule.cost_for_value(10)
    assert_equal 3, rule.cost_for_value(11)
    assert_equal 30, rule.cost_for_value(20)
    assert_equal 30, rule.cost_for_value(21)
    assert_equal 30, rule.cost_for_value(1_000_000_000)

    rule = @plan.pricing_rules.new(:min => 21, :cost_per_unit => 2)
    assert_equal 0, rule.cost_for_value(0)
    assert_equal 0, rule.cost_for_value(20)
    assert_equal 2, rule.cost_for_value(21)
    assert_equal 160, rule.cost_for_value(100)
    assert_equal 1_999_999_960, rule.cost_for_value(1_000_000_000)
  end

  should 'return correct cost for value on collection' do
    rules = @plan.pricing_rules

    rules.create!(:min => 1, :max => 10, :cost_per_unit => 4)
    rules.create!(:min => 11, :max => 20, :cost_per_unit => 3)
    rules.create!(:min => 21, :cost_per_unit => 2)

    assert_equal 0, rules.cost_for_value(0)
    assert_equal 4, rules.cost_for_value(1)
    assert_equal 40, rules.cost_for_value(10)
    assert_equal 43, rules.cost_for_value(11)
    assert_equal 70, rules.cost_for_value(20)
    assert_equal 72, rules.cost_for_value(21)
    assert_equal 2_000_000_030, rules.cost_for_value(1_000_000_000)
  end
end
