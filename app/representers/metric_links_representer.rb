# frozen_string_literal: true

module MetricLinksRepresenter
  extend ActiveSupport::Concern
  included do

    link :metric do
      return unless metric

      if metric.method_metric?
        admin_api_service_metric_method_url(metric.service, metric.parent, metric.id)
        # public_send("admin_api_#{metric.owner_type.underscore}_metric_method_url", metric.owner, metric.parent, metric.id) # TODO: in https://github.com/3scale/porta/pull/1201
      else
        public_send("admin_api_#{metric.owner_type.underscore}_metric_url", metric.owner, metric.id)
      end
    end
  end
end
