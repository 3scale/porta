require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UsageLimitTest < ActiveSupport::TestCase
  should validate_presence_of :metric
  # should_validate_presence_of :plan #plan.customize method hinders this validation

  should allow_value(0).for(:value)
  should allow_value('minute').for(:period)
  should allow_value('hour').for(:period)
  should allow_value('day').for(:period)
  should allow_value('week').for(:period)
  should allow_value('month').for(:period)
  should allow_value('year').for(:period)
  should_not allow_value('century').for(:period)
  should_not allow_value('fake').for(:period)

  test 'period_range' do
    Timecop.freeze(Time.zone.local(2009, 6, 11, 16, 45, 22)) do
      assert_equal Time.utc(2009, 6, 11, 16, 45, 22)..Time.utc(2009, 6, 11, 16, 45, 23),
                   UsageLimit.period_range(:second)

      assert_equal Time.utc(2009, 6, 11, 16, 45, 00)..Time.utc(2009, 6, 11, 16, 45, 59),
                   UsageLimit.period_range(:minute)

      assert_equal Time.utc(2009, 6, 11, 16, 00, 00)..Time.utc(2009, 6, 11, 16, 59, 59),
                   UsageLimit.period_range(:hour)

      assert_equal Time.utc(2009, 6, 11, 00, 00, 00)..Time.utc(2009, 6, 11).end_of_day,
                   UsageLimit.period_range(:day)

      assert_equal Time.utc(2009, 6, 8)..Time.utc(2009, 6, 8).end_of_week,
                   UsageLimit.period_range(:week)

      assert_equal Time.utc(2009, 6, 1)..Time.utc(2009, 6, 1).end_of_month,
                   UsageLimit.period_range(:month)

      assert_equal Time.utc(2009, 1, 1)..Time.utc(2009, 12, 1).end_of_month,
                   UsageLimit.period_range(:year)
    end
  end

  test 'value default_value' do
    l = UsageLimit.new(:period => 'week')
    l.metric = Factory(:metric)
    l.plan = Factory(:simple_application_plan)
    l.save!

    assert l.value.zero?
  end

  test  'value default_value for values < 0' do
    l = UsageLimit.new(:period => 'week', value: -1)
    l.metric = Factory(:metric)
    l.plan = Factory(:simple_application_plan)
    l.save!

    assert l.value.zero?
  end

end
