require 'test_helper'

class Stats::Views::UsageTest < ActiveSupport::TestCase

  def setup
    Time.zone = 'UTC'
    @dummy = DummyClass.new
    @metric = FactoryBot.build_stubbed(:metric)
    @dummy.stubs(:extract_metric).returns(@metric)

    @options = { since: '2010-01-01',
                 until: '2010-01-02',
                 granularity: :day,
                 timezone: 'UTC', metric_name: 'foo'}
  end

  class DummyClass < Stats::Base
    include Stats::Views::Usage
  end

  test '#usage should have correct previous range' do
    d1 = Time.zone.parse('2009-12-30')
    d2 = Time.zone.parse('2009-12-31 23:59:59')

    range = TimeRange.new(d1, d2)

    @dummy.expects(:usage_values_in_range).returns([0])
    @dummy.expects(:usage_values_in_range).once.with(range, :day, @metric).returns([0])
    @dummy.usage_progress(@options)
  end

  test "#usage doesn't calculate previous if not needed" do
    @dummy.expects(:usage_values_in_range).once.returns([0])
    @dummy.usage(@options.merge(skip_change: true))
  end

  test '#usage raises InvalidParameterError when :since is invalid date format' do
     assert_raise Stats::InvalidParameterError do
      @dummy.usage(@options.merge(since: '201501-01'))
     end
  end


  test "#usage calculates previous if asked for it" do
    d1 = Time.zone.parse('2009-12-30')
    d2 = Time.zone.parse('2009-12-31 23:59:59')

    range = TimeRange.new(d1, d2)

    @dummy.expects(:usage_values_in_range).twice.returns([0])
    @dummy.usage(@options.merge(skip_change: false))
  end
end
