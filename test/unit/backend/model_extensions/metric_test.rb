require 'test_helper'

class Backend::ModelExtensions::MetricTest < ActiveSupport::TestCase
  test 'sync backend metric data when metric is created' do
    service = FactoryBot.create(:simple_service)
    metric = Metric.new(service: service, system_name: 'koos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:perform_later)

    metric.save!
  end

  test 'sync backend metric data when metric is updated' do
    service = FactoryBot.create(:simple_service)
    metric = Metric.new(service: service, system_name: 'foos', friendly_name: 'Foos', unit: 'foo')

    BackendMetricWorker.expects(:perform_later)
    metric.save!

    metric.system_name = 'bars'
    BackendMetricWorker.expects(:perform_later).with(service.backend_id, metric.id)

    metric.save!
  end

  test 'does not sync backend metric when validation fails creating a nested metric (method)' do
    service = FactoryBot.create(:simple_service)
    metric  = FactoryBot.create(:metric, :service => service, :friendly_name => 'Foos')

    Metric.any_instance.expects(:sync_backend).never
    BackendMetricWorker.expects(:perform_later).never

    child = metric.children.create

    refute child.valid?
  end

  test 'does not sync backend metric data when validation fails' do
    service = FactoryBot.create(:simple_service)
    metric  = FactoryBot.create(:metric, :service => service, :friendly_name => 'Foos')

    BackendMetricWorker.expects(:perform_later).never

    metric.system_name = '$$$' # <-- this metric name is definitely invalid
    metric.save

    refute metric.valid?
  end

  test 'sync backend metric data when metric is destroyed' do
    metric = FactoryBot.create(:metric)

    BackendMetricWorker.expects(:perform_later).with(metric.service.backend_id, metric.id)

    metric.destroy
  end

  test 'sync backend api metric for multiple services' do
    services = FactoryBot.create_list(:simple_service, 2, :with_default_backend_api)
    backend_api = services.first.backend_api
    services.last.backend_api_configs.create(backend_api: backend_api, path: 'other') # other service using the same BackendApi
    metric = FactoryBot.build(:metric, service: nil, owner: backend_api)

    services.each { |service| BackendMetricWorker.expects(:perform_later).with(service.backend_id, metric.id) }
    metric.sync_backend

    services.each { |service| BackendMetricWorker.expects(:perform_now).with(service.backend_id, metric.id) }
    metric.sync_backend!
  end

  test 'sync metric for single service' do
    service = FactoryBot.create(:simple_service)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    metric = backend_api.metrics.hits

    BackendMetricWorker.expects(:perform_later).with(service.backend_id, metric.id)
    metric.sync_backend_for_service(service)

    BackendMetricWorker.expects(:perform_now).with(service.backend_id, metric.id)
    metric.sync_backend_for_service!(service)
  end
end
