class Admin::Api::MetricsBaseController < Admin::Api::ServiceBaseController

  protected

    def metric
      raise NotImplementedError.new "#{self.class.name} should implemented metric method"
    end

    def metrics
      @metrics ||= service.metrics
    end

    def metric_params
      parameters = params.fetch(:metric)

      if parameters[:name].present?
        # as of February 2014, notify that this provider is using a deprecated api
        deprecated_api "`name' parameter for metric/method api was deprecated, `system_name' should be used for provider #{current_account.id}/#{current_account.org_name}"
        parameters[:system_name] = parameters[:name] unless parameters[:system_name].present?
      end
      # let's ignore name parameter
      parameters.except(:name)
    end
end
