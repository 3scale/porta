module ThreeScale::ErrorReportingIgnoreEnduser

  if defined?(::NewRelic)
    require 'new_relic/agent/instrumentation/controller_instrumentation'

    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  end

  def self.included(base)
    base.extend(BaseClassMethods)
  end

  module BaseClassMethods

    def error_reporting_ignore_enduser(*args)
      return unless new_relic_instrumentation?

      newrelic_ignore_enduser(*args)
    end

    def new_relic_instrumentation?
      defined?(::NewRelic::Agent::Instrumentation::ControllerInstrumentation)
    end
  end
end
