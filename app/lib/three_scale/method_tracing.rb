# frozen_string_literal: true

module ThreeScale
  module MethodTracing

    if defined?(::NewRelic)
      require 'new_relic/agent/method_tracer'

      include ::NewRelic::Agent::MethodTracer
    end

    def self.included(base)
      base.extend(BaseClassMethods)
    end

    module BaseClassMethods

      def add_three_scale_method_tracer(*attrs)
        return unless new_relic_method_tracer?

        add_method_tracer(*attrs)
      end

      def new_relic_method_tracer?
        defined?(::NewRelic::Agent::MethodTracer)
      end
    end
  end
end
