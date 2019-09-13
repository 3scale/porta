require 'test_helper'

class Backend::ModelExtensions::MetricTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test 'sync backend metric data when metric is created' do
    service = FactoryBot.create(:simple_service)
    metric = Metric.new(service: service, system_name: 'koos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:perform_async)

    metric.save!
  end

  test 'sync backend metric data when metric is updated' do
    service = FactoryBot.create(:simple_service)
    metric = Metric.new(service: service, system_name: 'foos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:perform_async)
    metric.save!

    metric.system_name = 'bars'
    BackendMetricWorker.expects(:perform_async).with(service.backend_id, metric.id, metric.system_name)

    metric.save!
  end

  test 'does not sync backend metric when validation fails creating a nested metric (method)' do
    service = FactoryBot.create(:simple_service)
    metric  = FactoryBot.create(:metric, :service => service, :friendly_name => 'Foos')

    Metric.any_instance.expects(:sync_backend).never
    BackendMetricWorker.expects(:perform_async).never

    child = metric.children.create

    refute child.valid?
  end

  test 'does not sync backend metric data when validation fails' do
    service = FactoryBot.create(:simple_service)
    metric  = FactoryBot.create(:metric, :service => service, :friendly_name => 'Foos')

    BackendMetricWorker.expects(:perform_async).never

    metric.system_name = '$$$' # <-- this metric name is definitely invalid
    metric.save

    refute metric.valid?
  end

  test 'sync backend metric data when metric is destroyed' do
    metric = FactoryBot.create(:metric)

    BackendMetricWorker.expects(:perform_async).with(metric.service.backend_id, metric.id, metric.system_name)

    metric.destroy
  end

  test 'sync backend metric data multiple times under race condition' do
    class MetricWithFiber < ::Metric
      def destroy
        super
        Fiber.yield
      end
    end

    service = FactoryBot.create(:simple_service)
    metric = MetricWithFiber.create(service: service, friendly_name: 'My metric', unit: 'hits')
    metric_id = metric.id

    ::BackendMetricWorker.expects(:perform_async).with(service.backend_id, metric_id, metric.system_name).twice

    metric_f1 = MetricWithFiber.find(metric_id)
    metric_f2 = MetricWithFiber.find(metric_id)

    f1 = Fiber.new { metric_f1.destroy }
    f2 = Fiber.new { metric_f2.destroy }

    f1.resume
    f2.resume
    f1.resume
    f2.resume
  end

  test 'sync backend api metric for multiple services' do
    services = FactoryBot.create_list(:simple_service, 2)
    backend_api = services.first.first_backend_api
    services.last.backend_api_configs.create(backend_api: backend_api, path: 'other') # other service using the same BackendApi
    metric = FactoryBot.build(:metric, service: nil, owner: backend_api)

    services.each { |service| BackendMetricWorker.expects(:perform_async).with(service.backend_id, metric.id, metric.attributes['system_name']) }
    metric.sync_backend

    services.each { |service| BackendMetricWorker.any_instance.expects(:perform).with(service.backend_id, metric.id, metric.attributes['system_name']) }
    metric.sync_backend!
  end

  test 'sync metric for single service' do
    service = FactoryBot.create(:simple_service)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    metric = backend_api.metrics.hits

    BackendMetricWorker.expects(:perform_async).with(service.backend_id, metric.id, metric.attributes['system_name'])
    metric.sync_backend_for_service(service)

    BackendMetricWorker.any_instance.expects(:perform).with(service.backend_id, metric.id, metric.attributes['system_name'])
    metric.sync_backend_for_service!(service)
  end
end
