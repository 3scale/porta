# frozen_string_literal: true
require 'test_helper'

class SymbolizeTest < ActiveSupport::TestCase
  class UsageLimit < ApplicationRecord
    self.table_name = 'usage_limits'
    include Symbolize
    symbolize :period

    # Because it is null: false in DB
    before_save :set_plan_type

    private
    def set_plan_type
      self.plan_type ||= 'Plan'
    end
  end

  def test_symbolization
    usage = UsageLimit.new(period: 'year')
    assert_equal :year, usage.period
    usage.save!

    usage.reload
    assert_equal :year, usage.period
  end

  def test_period_change
    usage = UsageLimit.create!(period: 'year')

    usage.period = 'hour'
    assert_equal :hour, usage.period
    assert_equal [:year, :hour], usage.period_change
  end

  def test_period_previous_change
    usage = UsageLimit.create!(period: 'year')
    usage.period = 'hour'
    usage.save!
    assert_nil usage.period_change
    assert_equal [:year, :hour], usage.period_previous_change
  end

  test '#changes is symbolized but not #previous_changes' do
    usage = UsageLimit.new
    usage.period = 'hour'
    assert_equal({'period' => [nil, :hour]}, usage.changes)
    usage.save!

    usage.reload
    assert_equal({}, usage.changes)
    usage.period = 'day'
    assert_equal({'period' => [:hour, :day]}, usage.changes)

    usage.save!
    # FIXME: sadly previous_changes are not symbolized (yet)
    assert_equal({'period' => ['hour', 'day']}, usage.previous_changes)
  end

  test 'does not symbolizes other attribute' do
    usage = UsageLimit.new period: :hour
    usage.plan_type = 'ApplicationPlan'
    assert_equal [nil, 'ApplicationPlan'], usage.plan_type_change
    assert_equal 'ApplicationPlan', usage.plan_type

    usage.save!
    assert_equal [nil, 'ApplicationPlan'], usage.plan_type_previous_change
    usage.reload
    assert_equal 'ApplicationPlan', usage.plan_type
  end

end
