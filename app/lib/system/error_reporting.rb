# frozen_string_literal: true

class DeprecationWarning < StandardError
  def initialize(msg = nil, deprecation_horizon = nil)
    super(msg)
    @message = msg
    @deprecation_horizon = deprecation_horizon
  end

  attr_accessor :message, :deprecation_horizon
end

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
      exception = DeprecationWarning.new(payload[:message], payload[:deprecation_horizon])

      ::Bugsnag.notify(exception) do |report|
        report.severity = 'warning'
        report.grouping_hash = exception.message
        report.add_tab 'deprecation_horizon', { value: exception.deprecation_horizon }
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
