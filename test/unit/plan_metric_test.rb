require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PlanMetricTest < ActiveSupport::TestCase
  should validate_presence_of :plan
  should validate_presence_of :metric

  test "boolean fields default to true" do
    plan_metric = PlanMetric.new

    assert plan_metric.visible?
    assert plan_metric.limits_only_text?
  end

  test 'scope hidden' do
    plan_metric_visible = FactoryGirl.create(:plan_metric, visible: true)
    plan_metric_hidden = FactoryGirl.create(:plan_metric, visible: false)

    hidden_plan_metrics = PlanMetric.hidden.pluck(:id)
    assert_includes hidden_plan_metrics, plan_metric_hidden.id
    assert_not_includes hidden_plan_metrics, plan_metric_visible.id
  end

  test 'visible?' do
    plan = FactoryGirl.create(:application_plan)
    metric_with_visible_plan_metric = FactoryGirl.create(:plan_metric, visible: true, plan: plan).metric
    metric_with_hidden_plan_metric = FactoryGirl.create(:plan_metric, visible: false, plan: plan).metric
    metric_without_plan_metric = FactoryGirl.create(:metric)

    assert PlanMetric.visible?(plan: plan, metric: metric_with_visible_plan_metric)
    assert PlanMetric.visible?(plan: plan, metric: metric_without_plan_metric)
    refute PlanMetric.visible?(plan: plan, metric: metric_with_hidden_plan_metric)
  end

end
