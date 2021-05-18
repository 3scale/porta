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

  test '#usage raises InvalidParameterError when range is more than one year for day granularity' do
    assert_raise Stats::InvalidParameterError do
      @dummy.usage(@options.merge!(until: '2011-01-01'))
    end
  end


  test '#usage raises InvalidParameterError when range is more than 90 days for hour granularity' do
    assert_raise Stats::InvalidParameterError do
      @dummy.usage(@options.merge!(until: '2010-04-01', granularity: :hour))
    end
  end

  test '#usage raises InvalidParameterError when range is more than 10 years for month granularity' do
    assert_raise Stats::InvalidParameterError do
      @dummy.usage(@options.merge!(until: '2020-01-01', granularity: :month))
    end
  end

  test "#usage won't raise an Error when range is less than one year for day granularity" do
    assert_nothing_raised do
      @dummy.usage(@options.merge!(until: '2010-12-31'))
    end
  end

  test "#usage won't raise an Error when range is less than 90 days for hour granularity" do
    assert_nothing_raised do
      @dummy.usage(@options.merge!(until: '2010-03-31', granularity: :hour))
    end
  end

  test "#usage won't raise an Error when range is less than 10 years for month granularity" do
    assert_nothing_raised do
      @dummy.usage(@options.merge!(until: '2019-12-31', granularity: :month))
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
