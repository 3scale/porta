module Stats
  class Client < Base
    include Views::Usage
    include Views::Total

    def initialize(cinstance)
      @cinstance = cinstance
      super(cinstance.service, cinstance)
    end

    def usage(options)
      super.tap { |result| append_utilization(result) }
    end

    def client
      account = @cinstance.user_account

      {:client_name => account.org_name,
       :client_id   => account.id,
       :plan_name   => @cinstance.plan.name }
    end

    def source_key
      [@cinstance.service, {:cinstance => @cinstance.application_id}]
    end

    private

    def append_utilization(result)
      metrics = @cinstance.service.metrics
      records = @cinstance.backend_object.utilization(metrics)
      return if records.error? || records.empty?

      result[:utilization] = records.map do |record|
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
