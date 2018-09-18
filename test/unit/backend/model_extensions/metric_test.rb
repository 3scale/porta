require 'test_helper'

class Backend::ModelExtensions::MetricTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test 'sync backend metric data when metric is created' do
    service = Factory(:simple_service)
    metric = Metric.new(service: service, system_name: 'koos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:sync)

    metric.save!
  end

  test 'sync backend metric data when metric is updated' do
    service = Factory(:simple_service)
    metric = Metric.new(service: service, system_name: 'foos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:sync)
    metric.save!

    metric.system_name = 'bars'
    BackendMetricWorker.expects(:sync).with(service.backend_id, metric.id, metric.name)

    metric.save!
  end

  test 'does not sync backend metric when validation fails creating a nested metric (method)' do
    service = Factory(:simple_service)
    metric  = Factory(:metric, :service => service, :friendly_name => 'Foos')

    Metric.any_instance.expects(:sync_backend).never
    BackendMetricWorker.expects(:sync).never

    child = metric.children.create

    refute child.valid?
  end

  test 'does not sync backend metric data when validation fails' do
    service = Factory(:simple_service)
    metric  = Factory(:metric, :service => service, :friendly_name => 'Foos')

    BackendMetricWorker.expects(:sync).never

    metric.system_name = '$$$' # <-- this metric name is definitely invalid
    metric.save

    refute metric.valid?
  end

  test 'sync backend metric data when metric is destroyed' do
    metric = Factory(:metric)

    BackendMetricWorker.expects(:sync).with(metric.service.backend_id, metric.id, metric.name)

    metric.destroy
  end
end
