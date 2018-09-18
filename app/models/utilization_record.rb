class UtilizationRecord < ThreeScale::Core::Utilization

  attributes :period, :max_value, :current_value, :metric

  attr_reader :percentage

  delegate :friendly_name, :system_name, to: :metric
  alias metric_name system_name

  def initialize(attributes)
    super

    @percentage = _percentage
    freeze
  end

  def finite?
    !infinite?
  end

  def infinite?
    max_value.to_f == 0.0
  end

  private

  def _percentage
    return 0.0 if max_value.to_f <= 0.0

    value = (current_value.to_f / max_value.to_f) * 100.0
    (value * 100).to_i / 100.0
  end
end
