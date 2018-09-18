# frozen_string_literal: true

module Logic
  module MetricVisibility
    module Plan
      ## same methods as on Metric
      #  but it uses internal cache to prevent multiple queries to db
      def metric_enabled?(metric)
        usage_limits.of_metric(metric).none?{|limit| limit.value == 0 }
      end

      def metric_visible?(metric)
        pm = plan_metrics.of_metric(metric).first
        pm ? pm.visible? : true
      end

      def limits_only_text?(metric)
        pm = plan_metrics.of_metric(metric).first
        pm ? pm.limits_only_text? : true
      end
    end

    module OfMetricAssociationProxy
      include System::AssociationExtension

      def of_metric(metric)
        if loaded?
          select{ |record| record.metric_id == metric.id }
        else
          where(:metric_id => metric.id)
        end
      end
    end
  end
end
