module LastTraffic
  module_function

  DEFAULT_METRIC = 'hits'.freeze

  def send_traffic_in_day(cinstance, timestamp)
    LastTrafficWorker.perform_in(timestamp + 1.day, cinstance.user_account_id, timestamp.to_i)
  end

  # @param [Account] provider
  # @param [Time] time
  def sent_traffic_on(provider, time)
    date = time.to_date
    timestamp = time.end_of_day

    provider_traffic = TrafficService.build(provider, metric_name: DEFAULT_METRIC)
    analytics_options = { date: date, timestamp: timestamp, metric_name: provider_traffic.metric_name }

    day_traffic, * = provider_traffic.per_day(since: date, till: date)
    month_traffic, * = provider_traffic.total(since: date.beginning_of_month, till: date)

    analytics = ThreeScale::Analytics.account_tracking(provider)
    analytics.with_segment_options(timestamp: timestamp) do
      analytics.track('Daily Traffic', analytics_options.merge(value: day_traffic))
      analytics.track('Month Traffic', analytics_options.merge(value: month_traffic))
    end

    day_traffic
  end
end
