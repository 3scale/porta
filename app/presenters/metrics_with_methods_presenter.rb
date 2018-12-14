# frozen_string_literal: true

class MetricsWithMethodsPresenter
  def initialize(metrics: [], methods: [], plan:)
    convert_to_metric_presenter = proc { |metric| MetricPresenter.new(metric, metric.visible_in_plan?(plan)) }
    wrap_collection_to_metric_presenter = proc { |metrics_collection| metrics_collection.map(&convert_to_metric_presenter) }
    @metrics = wrap_collection_to_metric_presenter.call(metrics)
    @methods = wrap_collection_to_metric_presenter.call(methods)
  end

  attr_reader :metrics, :methods
end
