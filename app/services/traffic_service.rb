class TrafficService
  attr_reader :metric_name

  attr_reader :stats_client
  protected :stats_client

  # @param [Stats::Client] stats_client
  # @param [String] metric_name
  def initialize(stats_client, metric_name: 'hits'.freeze)
    @stats_client = stats_client
    @metric_name = metric_name
  end

  def per_day(since: , till: nil, metric_name: self.metric_name)
    till ||= now

    usage = stats_client.usage(
        metric_name: metric_name,
        since: since,
        until: till,
        granularity: :day,
        timezone: till.acts_like?(:time) ? till.zone : Time.zone.name
    )

    usage[:values]
  end

  def total(since: , till: now)
    per_day(since: since, till: till).reduce(:+)
  end

  def last_traffic_date(since: 1.year.ago, till: now)
    usage = per_day(since: since, till: till)

    # given the range 2015-01-01 to 2015-01-07
    # if the traffic was on 2015-01-03 which is 3rd from start, but 5th from end
    # we count the first element that had traffic from the end, using its index
    # and subtracting it from the end date. so 2015-01-07 - 4 (5th) = 2015-01-03

    days_ago = usage.reverse.find_index{|i| i > 0 }

    return unless days_ago

    till.to_date - days_ago
  end

  def now
    Time.zone.now
  end

  # @param [Account] account
  def self.build(account, **options)
    cinstance = account.bought_cinstance
    client = Stats::Client.new(cinstance)

    new(client, **options)
  end
end
