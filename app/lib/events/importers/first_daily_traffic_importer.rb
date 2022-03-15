# frozen_string_literal: true

require_dependency 'events/importers/base_importer'

module Events
  module Importers
    class FirstDailyTrafficImporter < BaseImporter
      def save!
        return unless cinstance

        cinstance.update_attribute(:first_daily_traffic_at, object.timestamp)
        notify_segment
        true
      end

      def notify_segment
        analytics = user_tracking
        timestamp = cinstance.first_daily_traffic_at

        return unless timestamp && analytics

        analytics.with_segment_options(timestamp: timestamp) do
          analytics.track('Traffic Sent', date: timestamp.to_date, timestamp: timestamp) if LastTraffic.send_traffic_in_day(cinstance, timestamp)
        end
      end
    end
  end
end
