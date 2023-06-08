# frozen_string_literal: true

module System
  module ErrorReporting
    module_function

    def report_error(exception, logger: Rails.logger, **parameters)
      logger.error('Exception') { {exception: {class: exception.class, message: (exception.try(:message) || exception.to_s), backtrace: (exception.try(:backtrace) || [])[0..3]}, parameters: parameters} }

      ::Bugsnag.notify(exception) do |report|
        report.add_tab 'parameter', {parameters: parameters}
      end
    end

    def report_deprecation_warning(payload)
      message = payload[:message]
      deprecation_horizon = payload[:deprecation_horizon]

      ::Bugsnag.notify(message) do |report|
        report.severity = 'warning'
        report.grouping_hash = message
        report.add_tab 'deprecation_horizon', { description: "Rails version that won't have this feature available", value: deprecation_horizon }
      end
    end

    class LogFormatter < ActiveSupport::Logger::SimpleFormatter

      def initialize
        super
        extend ActiveSupport::TaggedLogging::Formatter
      end

      # Logger interface suffers from :reek:LongParameterList and :reek:FeatureEnvy
      def call(severity, timestamp, progname, msg)
        msg = case msg
              when ::Exception
                +"#{ msg.message } (#{ msg.class })\n" << (msg.backtrace || []).join("\n") + "\n"
              else
                super
              end
        progname ? "#{progname} -- #{msg}" : msg
      end
    end
  end
end
