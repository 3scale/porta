require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PlanMetricTest < ActiveSupport::TestCase
  should validate_presence_of :plan
  should validate_presence_of :metric

  test "boolean fields default to true" do
    plan_metric = PlanMetric.new

    assert plan_metric.visible?
    assert plan_metric.limits_only_text?
  end

end
