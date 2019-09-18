# frozen_string_literal: true

module MetricLinksRepresenter
  extend ActiveSupport::Concern
  included do

    link :metric do
      return unless metric

      if metric.method_metric?
        # TODO: in https://github.com/3scale/porta/pull/1201
        admin_api_service_metric_method_url(metric.service, metric.parent, metric.id)
      else
        polymorphic_url([:admin, :api, metric.owner, metric])
      end
    end
  end
end
