require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Liquid::Drops::ApplicationPlanDropTest < ActiveSupport::TestCase
  context 'ApplicationPlanDrop' do
    setup do
      @plan = Factory(:application_plan)
      2.times { |u| Factory(:usage_limit, :plan => @plan) }
      @drop = Liquid::Drops::ApplicationPlan.new(@plan)
    end

    should 'return id' do
      assert_equal @drop.id, @plan.id
    end

    should 'wrap usage_limits' do
      assert_equal 2, @drop.usage_limits.size
      assert @drop.usage_limits.all?  { |d| d.class == Liquid::Drops::UsageLimit }
    end

    should 'wrap metrics' do
      assert_equal 1, @drop.metrics.size
      assert @drop.metrics.all?  { |d| d.class == Liquid::Drops::Metric }
    end
  end
end
