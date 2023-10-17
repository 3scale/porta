# frozen_string_literal: true

class LastTraffic
  DEFAULT_METRIC = 'hits'

  # @param [Account] provider
  def initialize(provider)
    @provider = provider
  end

  def self.send_traffic_in_day(cinstance, timestamp)
    LastTrafficWorker.perform_in(timestamp + 1.day, cinstance.user_account_id, timestamp.to_i)
  end

  # @param [Time] time
  def sent_traffic_on(time)
    date = time.to_date
    timestamp = time.end_of_day

    traffic_data = {
      day: traffic_service.per_day(since: date, till: date).first,
      month: traffic_service.total(since: date.beginning_of_month, till: date)
    }

    send_to_analytics(date, timestamp, traffic_data)

    traffic_data[:day]
  end

  private

  def traffic_service
    @traffic_service ||= TrafficService.build(@provider, metric_name: DEFAULT_METRIC)
  end

  def send_to_analytics(date, timestamp, traffic_data)
    options = { date: date, timestamp: timestamp, metric_name: traffic_service.metric_name }

    analytics.with_segment_options(timestamp: timestamp) do
      analytics.track('Daily Traffic', options.merge(value: traffic_data[:day]))
      analytics.track('Month Traffic', options.merge(value: traffic_data[:month]))
    end
  end

  def analytics
    @analytics ||= ThreeScale::Analytics.account_tracking(@provider)
  end
end
