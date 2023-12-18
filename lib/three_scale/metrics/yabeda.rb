# frozen_string_literal: true

# Based on https://github.com/yabeda-rb/yabeda-rails/blob/v0.8.1/lib/yabeda/rails.rb

require "yabeda"
require "active_support"
require "rails/railtie"

module ThreeScale
  module Metrics
    module Yabeda
      TIME_BUCKETS = [
        0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, # standard
        40, # default Unicorn timeout
      ].freeze

      class << self
        def install!
          ::Yabeda.configure do
            group :rails

            counter   :requests_total, comment: "A counter of the total number of HTTP requests rails processed.",
                      tags: %i[controller status]

            histogram :request_duration,
                      unit: :seconds,
                      buckets: TIME_BUCKETS,
                      comment: "A histogram of the response latency."

            ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
              event = ActiveSupport::Notifications::Event.new(*args)
              labels = {
                controller: event.payload[:params]["controller"],
                status: ThreeScale::Metrics::Yabeda.event_status_code_class(event),
              }.merge!(event.payload.slice(*::Yabeda.default_tags.keys))

              rails_requests_total.increment(labels)
              rails_request_duration.measure({}, ThreeScale::Metrics::Yabeda.ms2s(event.duration))
            end
          end
        end

        def ms2s(milliseconds)
          (milliseconds / 1000.0).round(3)
        end

        def event_status_code_class(event)
          code = if event.payload[:status].nil? && event.payload[:exception].present?
                   ActionDispatch::ExceptionWrapper.status_code_for_exception(event.payload[:exception].first)
                 else
                   event.payload[:status]
                 end
          status_class(code)
        end

        def status_class(code)
          case code
          when (100...200)
            '1xx'
          when (200...300)
            '2xx'
          when (300...400)
            '3xx'
          when (400...500)
            '4xx'
          when (500...600)
            '5xx'
          else
            'unknown'
          end
        end
      end
    end
  end
end
