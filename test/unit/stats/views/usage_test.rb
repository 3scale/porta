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
    # should work
    @dummy.usage(@options.merge!(until: '2010-12-31'))

    assert_raise Stats::InvalidParameterError do
      @dummy.usage(@options.merge!(until: '2011-01-01'))
    end
  end


  test '#usage raises InvalidParameterError when range is more than 90 days for hour granularity' do
    # should work
    @dummy.usage(@options.merge!(until: '2010-03-31', granularity: :hour))

    assert_raise Stats::InvalidParameterError do
      @dummy.usage(@options.merge!(until: '2010-04-01', granularity: :hour))
    end
  end

  test '#usage raises InvalidParameterError when range is more than 10 years for month granularity' do
    # should work
    @dummy.usage(@options.merge!(until: '2019-12-31', granularity: :month))

    assert_raise Stats::InvalidParameterError do
      @dummy.usage(@options.merge!(until: '2020-01-01', granularity: :month))
    end
  end

  test "#usage calculates previous if asked for it" do
    d1 = Time.zone.parse('2009-12-30')
    d2 = Time.zone.parse('2009-12-31 23:59:59')

    range = TimeRange.new(d1, d2)

    @dummy.expects(:usage_values_in_range).twice.returns([0])
    @dummy.usage(@options.merge(skip_change: false))
  end

  ;  test '#usage with period eternity does not compute previous' do
    @dummy.expects(:usage_values_in_range).once.returns([10, 20])

    result = @dummy.usage(period: 'eternity', since: '2010-01-01', metric_name: 'foo', timezone: 'UTC', skip_change: false)

    assert_equal 'eternity', result[:period][:name]
    assert_nil result[:previous_total]
    assert_nil result[:change]
  end

  test '#usage with period eternity honors since parameter' do
    @dummy.expects(:usage_values_in_range).once.returns([0])

    result = @dummy.usage(period: 'eternity', since: '2015-06-15', metric_name: 'foo', timezone: 'UTC')

    assert_equal '2015-01-01', result[:period][:since].strftime('%Y-%m-%d')
  end

  test '#usage with period eternity defaults since to service created_at' do
    service = FactoryBot.build_stubbed(:service, created_at: Time.utc(2012, 6, 15))
    dummy = DummyClass.new(service)
    dummy.stubs(:extract_metric).returns(@metric)
    dummy.expects(:usage_values_in_range).once.returns([0])

    result = dummy.usage(period: 'eternity', metric_name: 'foo', timezone: 'UTC')

    assert_equal '2012-01-01', result[:period][:since].strftime('%Y-%m-%d')
  end

  test '#usage with period eternity ignores until and defaults to end of current year' do
    @dummy.expects(:usage_values_in_range).once.returns([0])

    travel_to(Time.utc(2020, 6, 15)) do
      result = @dummy.usage(period: 'eternity', since: '2010-01-01', until: '2018-01-01', metric_name: 'foo', timezone: 'UTC')

      assert_equal '2020-12-31', result[:period][:until].strftime('%Y-%m-%d')
    end
  end

  test '#usage returns nil if application data does not exist' do
    @dummy.instance_variable_set(:@cinstance, nil)

    assert_nil(@dummy.usage(@options)[:application])
  end

  test '#usage returns application data if it exists' do
    application_plan = FactoryBot.build_stubbed(:application_plan, id: 1, name: 'Application Plan')
    account = FactoryBot.build_stubbed(:account, id: 1, name: 'Account')
    service = FactoryBot.build_stubbed(:service, id: 1)
    cinstance = FactoryBot.build_stubbed(
      :cinstance,
      id: 1,
      name: 'Application',
      state: 'live',
      plan: application_plan,
      user_account: account,
      service: service
    )

    @dummy.instance_variable_set(:@cinstance, cinstance)

    assert_equal(
      {
        id: 1,
        name: 'Application',
        state: 'live',
        link: '/p/admin/applications/1',
        description: nil,
        plan: {
          id: 1,
          name: 'Application Plan'
        },
        account: {
          id: 1,
          name: 'Account',
          link: '/buyers/accounts/1'
        },
        service: {
          id: 1
        }
      },
      @dummy.usage(@options)[:application]
    )
  end
end
