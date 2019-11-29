# frozen_string_literal: true

module System
  module ErrorReporting
    module_function

    def report_error(exception, logger: Rails.logger, **parameters)
      logger.error('Exception') { {exception: {class: exception.class, message: (exception.try(:message) || exception.to_s), backtrace: (exception.try(:backtrace) || [])[0..3]}, parameters: parameters} }

      ::Bugsnag.notify(exception) do |report|
        report.add_tab 'parameter', {parameters: parameters}
      end
      ::NewRelic::Agent.notice_error(exception) if defined?(::NewRelic)
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
