# frozen_string_literal: true

module MetricLinksRepresenter
  extend ActiveSupport::Concern
  included do

    link :metric do
      return unless metric

      if metric.method_metric?
        polymorphic_url([:admin, :api, metric.owner, metric.parent, :methods], id: metric.id)
      else
        polymorphic_url([:admin, :api, metric.owner, metric])
      end
    end
  end
end
