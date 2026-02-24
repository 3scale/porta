module Stats
  module Views
    module Utilization
      def utilization
        return unless @cinstance

        metrics = @cinstance.service.metrics
        records = @cinstance.backend_object.utilization(metrics)
        return if records.error? || records.empty?

        records.map do |record|
          {
            metric_name: record.system_name,
            friendly_name: record.friendly_name,
            period: record.period,
            current_value: record.current_value,
            max_value: record.max_value,
            percentage: record.percentage
          }
        end
      end
    end
  end
end
