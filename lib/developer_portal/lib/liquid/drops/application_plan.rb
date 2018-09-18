module Liquid
  module Drops
    class ApplicationPlan < ::Liquid::Drops::Plan
      allowed_name :application_plan

      desc "Returns the metrics of the plan."
      def metrics
        Drops::Metric.wrap(@plan.metrics)
      end

      desc "Returns the usage limits of the plan."
      def usage_limits
        Drops::UsageLimit.wrap(@plan.usage_limits)
      end

      desc "Returns the service of the plan."
      def service
        Drops::Service.new(@plan.service)
      end

    end
  end
end
