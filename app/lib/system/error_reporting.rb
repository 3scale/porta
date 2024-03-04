# frozen_string_literal: true

class DeprecationWarning < StandardError
  def initialize(msg = nil, gem_name = nil, deprecation_horizon = nil)
    super(msg)
    @message = msg
    @gem_name = gem_name
    @deprecation_horizon = deprecation_horizon
  end

  attr_accessor :message, :gem_name, :deprecation_horizon
end

module System
  module ErrorReporting
    module_function

    def report_error(exception, logger: Rails.logger, **parameters)
      logger.error('Exception') { {exception: {class: exception.class, message: (exception.try(:message) || exception.to_s), backtrace: (exception.try(:backtrace) || [])[0..3]}, parameters: parameters} }

      ::Bugsnag.notify(exception) do |report|
        report.add_metadata 'parameter', { parameters: parameters }
      end
    end

    def report_sidekiq_error(exception, _context, config)
      report_error(exception, logger: config.logger)
    end

    def report_deprecation_warning(payload)
      exception = DeprecationWarning.new(payload[:message], payload[:gem_name], payload[:deprecation_horizon])

      ::Bugsnag.notify(exception) do |report|
        report.severity = 'warning'
        report.grouping_hash = exception.message
        report.add_metadata 'deprecation_info', {
          gem_name: exception.gem_name,
          deprecation_horizon: exception.deprecation_horizon
        }
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
