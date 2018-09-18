require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

class Stats::Views::Csv::MetricsTest < ActiveSupport::TestCase

  def data_with_single_metric
    {:metric => {:system_name => 'foo_single', :name => "Foo Single"}, :values => [1,2,3,4,5]}
  end

  def data_with_array_of_metrics
    {:metrics => [
      {:system_name => 'foo_single_a', :name => "Foo Single A", :data => {:values => [1,2,3,4,5]}},
      {:system_name => 'foo_single_b', :name => "Foo Single B", :data => {:values => [6,7,8,9,0]}}
    ]}
  end

  test "returns an array" do
    assert_equal Stats::Views::Csv::Metrics.new(data_with_single_metric).collection.class, Array
    assert_equal Stats::Views::Csv::Metrics.new(data_with_array_of_metrics).collection.class, Array
  end

  test "returned array contains instances of Metric" do
    assert_equal Stats::Views::Csv::Metrics.new(data_with_single_metric).collection[0].class, Stats::Views::Csv::Metric
    assert_equal Stats::Views::Csv::Metrics.new(data_with_array_of_metrics).collection[0].class, Stats::Views::Csv::Metric
  end

  test "metric instance's properties represent a metric at it's values" do
    metric = Stats::Views::Csv::Metrics.new(data_with_single_metric).collection[0]

    assert_equal metric.system_name, "foo_single"
    assert_equal metric.name, "Foo Single"
    assert_equal metric.values, [1,2,3,4,5]

    metric = Stats::Views::Csv::Metrics.new(data_with_array_of_metrics).collection[0]

    assert_equal metric.system_name, "foo_single_a"
    assert_equal metric.name, "Foo Single A"
    assert_equal metric.values, [1,2,3,4,5]

    metric = Stats::Views::Csv::Metrics.new(data_with_array_of_metrics).collection[1]

    assert_equal metric.system_name, "foo_single_b"
    assert_equal metric.name, "Foo Single B"
    assert_equal metric.values, [6,7,8,9,0]

  end

end
