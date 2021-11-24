# frozen_string_literal: true

require 'test_helper'

class Liquid::Drops::ApplicationPlanDropTest < ActiveSupport::TestCase
  setup do
    @plan = FactoryBot.create(:application_plan)
    2.times { |u| FactoryBot.create(:usage_limit, :plan => @plan) }
    @drop = Liquid::Drops::ApplicationPlan.new(@plan)
  end

  test 'should return id' do
    assert_equal @drop.id, @plan.id
  end

  test 'should wrap usage_limits' do
    assert_equal 2, @drop.usage_limits.size
    assert(@drop.usage_limits.all?  { |d| d.instance_of?(Liquid::Drops::UsageLimit) })
  end

  test 'should wrap metrics' do
    assert_equal 1, @drop.metrics.size
    assert(@drop.metrics.all?  { |d| d.instance_of?(Liquid::Drops::Metric) })
  end
end
