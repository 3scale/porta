require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class MetricHelperTest < ActionView::TestCase
  test 'metric_name returns the friendly name of the metric' do
    metric = stub(:friendly_name => 'Enemies killed')
    assert_equal 'Enemies killed', metric_name(metric)
  end

  test 'metric_name return "missing" if the metric is nil' do
    assert_equal '<span class="missing">missing</span>', metric_name(nil)
  end
end
