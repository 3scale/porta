module MetricLinksRepresenter
  extend ActiveSupport::Concern

  included do

    link :metric do
      return unless metric

      if metric.method_metric?
        admin_api_service_metric_method_url(metric.service, metric.parent, metric)
      else
        admin_api_service_metric_url(metric.service, metric)
      end
    end
  end
end
