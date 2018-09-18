class Provider::Admin::Dashboard::Service::HitsController < Provider::Admin::Dashboard::Service::BaseController
  include ActiveSupport::NumberHelper

  protected

  def widget_data
    timeline_data(current_hits, previous_hits)
  end

  def current_hits
    @_current_hits ||= traffic_per_day(current_range)
  end

  def previous_hits
    @_previous_hits ||= traffic_per_day(previous_range)
  end

  def traffic_per_day(range)
    traffic = traffic_service.per_day(since: range.begin, till: range.end).map do |hits_count|
      {
        value:           hits_count,
        formatted_value: number_to_human(hits_count)
      }
    end

    range.to_a.zip(traffic).to_h
  end

  def traffic_service
    stats_client = Stats::Service.new(service)
    TrafficService.new(stats_client)
  end
end
