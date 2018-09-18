require 'test_helper'


class TrafficServiceTest < ActiveSupport::TestCase

  def setup
    @cinstance = FactoryGirl.build_stubbed(:simple_cinstance, id: 42)
    @stats = Stats::Client.new(@cinstance)
    @traffic_service = TrafficService.new(@stats)
  end

  def test_last_traffic_date_yesterday
    yesterday = Date.new(2015, 04, 13)
    time = yesterday.to_datetime.to_time.in_time_zone

    @stats.expects(:usage)
        .with(metric_name: 'hits', since: yesterday, until: yesterday, granularity: :day, timezone: 'UTC')
        .returns(values: [1])

    @stats.expects(:usage)
        .with(metric_name: 'hits', since: time, until: time, granularity: :day, timezone: 'UTC')
        .returns(values: [1])

    assert_equal yesterday, @traffic_service.last_traffic_date(since: yesterday, till: yesterday)
    assert_equal yesterday, @traffic_service.last_traffic_date(since: time, till: time)
  end

  def test_per_day

    range = (Date.new(2015, 04, 13)..Date.new(2015, 04, 21)).to_a
    from, *, to = range

    response = [ 0, 0 ] + [ 1 ] + [ 0, 0, 0, 0, 0, 0 ]

    assert_equal range.size, response.size

    @stats.expects(:usage)
        .with(metric_name: 'hits', since: from, until: to, granularity: :day, timezone: 'UTC')
        .returns(values: response)

    assert_equal response, @traffic_service.per_day(since: from, till: to)
  end

  def test_per_day_metric_name
    from, to = 1.day.ago, Time.now

    @stats.expects(:usage)
        .with(metric_name: 'transactions', since: from, until: to, granularity: :day, timezone: to.zone)
        .returns(values: [0])

    assert_equal [0], @traffic_service.per_day(since: from, till: to, metric_name: 'transactions')
  end


  def test_total
    range = (Date.new(2015, 04, 13)..Date.new(2015, 04, 21)).to_a
    from, *, to = range

    response = [ 0, 0 ] + [ 1 ] + [ 0, 0] + [1, 1] + [ 0, 0 ]

    assert_equal range.size, response.size

    @stats.expects(:usage)
        .with(metric_name: 'hits', since: from, until: to, granularity: :day, timezone: 'UTC')
        .returns(values: response)

    assert_equal 3, @traffic_service.total(since: from, till: to)
  end

  def test_build
    provider = FactoryGirl.build_stubbed(:simple_provider)
    provider.expects(bought_cinstance: FactoryGirl.build_stubbed(:simple_cinstance))

    service = TrafficService.build(provider, metric_name: 'foo')

    assert_equal 'foo', service.metric_name
  end
end
