require 'test_helper'

class Backend::ModelExtensions::MetricTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test 'sync backend metric data when metric is created' do
    service = FactoryBot.create(:simple_service)
    metric = Metric.new(service: service, system_name: 'koos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:sync)

    metric.save!
  end

  test 'sync backend metric data when metric is updated' do
    service = FactoryBot.create(:simple_service)
    metric = Metric.new(service: service, system_name: 'foos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:sync)
    metric.save!

    metric.system_name = 'bars'
    BackendMetricWorker.expects(:sync).with(service.backend_id, metric.id, metric.name)

    metric.save!
  end

  test 'does not sync backend metric when validation fails creating a nested metric (method)' do
    service = FactoryBot.create(:simple_service)
    metric  = FactoryBot.create(:metric, :service => service, :friendly_name => 'Foos')

    Metric.any_instance.expects(:sync_backend).never
    BackendMetricWorker.expects(:sync).never

    child = metric.children.create

    refute child.valid?
  end

  test 'does not sync backend metric data when validation fails' do
    service = FactoryBot.create(:simple_service)
    metric  = FactoryBot.create(:metric, :service => service, :friendly_name => 'Foos')

    BackendMetricWorker.expects(:sync).never

    metric.system_name = '$$$' # <-- this metric name is definitely invalid
    metric.save

    refute metric.valid?
  end

  test 'sync backend metric data when metric is destroyed' do
    metric = FactoryBot.create(:metric)

    BackendMetricWorker.expects(:sync).with(metric.service.backend_id, metric.id, metric.name)

    metric.destroy
  end

  test 'sync backend metric data only once when metric destroyed multiple times' do
    class MetricWithFiber < ::Metric
      def destroy_row
        Fiber.yield
        super
      end
    end

    service = FactoryBot.create(:simple_service)
    metric = MetricWithFiber.create(service: service, friendly_name: 'My metric', unit: 'hits')
    metric_id = metric.id

    ::BackendMetricWorker.expects(:sync).with(service.backend_id, metric_id, metric.system_name).once

    deletion = ->() do
      metric = MetricWithFiber.find(metric_id)
      metric.destroy
    end

    f1 = Fiber.new(&deletion)
    f2 = Fiber.new(&deletion)

    f1.resume
    f2.resume
    f1.resume
    f2.resume
  end
end
