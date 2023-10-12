# frozen_string_literal: true

# Based on https://github.com/yabeda-rb/yabeda-rails/blob/v0.8.1/lib/yabeda/rails.rb

require "yabeda"
require "active_support"
require "rails/railtie"

module ThreeScale
  module Metrics
    module Yabeda
      LONG_RUNNING_REQUEST_BUCKETS = [
        0.005, 0.01, 0.05, 0.1, 0.5, 1, 5, 10, # standard
        40, # default Unicorn timeout
      ].freeze

      class << self
        def controller_handlers
          @controller_handlers ||= []
        end

        def on_controller_action(&block)
          controller_handlers << block
        end

        def install!
          ::Yabeda.configure do
            group :rails

            counter   :requests_total,   comment: "A counter of the total number of HTTP requests rails processed.",
                      tags: %i[controller action status]

            histogram :request_duration, tags: %i[controller action status],
                      unit: :seconds,
                      buckets: LONG_RUNNING_REQUEST_BUCKETS,
                      comment: "A histogram of the response latency."

            ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
              event = ActiveSupport::Notifications::Event.new(*args)
              labels = {
                controller: event.payload[:params]["controller"],
                action: event.payload[:params]["action"],
                status: ThreeScale::Metrics::Yabeda.event_status_code(event),
              }.merge!(event.payload.slice(*::Yabeda.default_tags.keys))

              rails_requests_total.increment(labels)
              rails_request_duration.measure(labels, ThreeScale::Metrics::Yabeda.ms2s(event.duration))

              ThreeScale::Metrics::Yabeda.controller_handlers.each do |handler|
                handler.call(event, labels)
              end
            end
          end
        end

        def ms2s(milliseconds)
          (milliseconds / 1000.0).round(3)
        end

        def event_status_code(event)
          if event.payload[:status].nil? && event.payload[:exception].present?
            ActionDispatch::ExceptionWrapper.status_code_for_exception(event.payload[:exception].first)
          else
            event.payload[:status]
          end
        end
      end
    end
  end
end
