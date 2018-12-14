# frozen_string_literal: true

class MetricPresenter
  def initialize(metric, visible)
    @metric = metric
    @visible = visible
  end

  DELEGATED_METHODS = Metric.attribute_names.map(&:to_sym) | %i[name errors]
  delegate(*DELEGATED_METHODS, to: :metric)

  attr_reader :visible

  private

  attr_reader :metric
end
