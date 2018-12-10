# frozen_string_literal: true

module System
  module ErrorReporting
    module_function

    OPTIONS = lambda do |parameters, rack_env = nil|
      options = parameters.present? ? { parameters: parameters } : {}

      options[:rack_env] = rack_env if rack_env
      options
    end

    def report_error(exception, rack_env: nil, logger: Rails.logger, **parameters)
      options = OPTIONS.call(parameters, rack_env)

      logger.error('Exception') { {exception: {class: exception.class, message: (exception.try(:message) || exception.to_s), backtrace: (exception.try(:backtrace) || [])[0..3]}, parameters: parameters} }

      ::Airbrake.notify_or_ignore(exception, options) if defined?(Airbrake)
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
