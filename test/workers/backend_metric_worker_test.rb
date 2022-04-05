# frozen_string_literal: true

require 'test_helper'

class BackendMetricWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @service = FactoryBot.create(:simple_service)
    @metric = FactoryBot.create(:metric, service: service, system_name: 'some_system_name')
  end

  attr_reader :service, :metric

  test '#perform for update metric' do
    ThreeScale::Core::Metric.expects(:save).with(id: metric.id, service_id: service.backend_id, name: metric.system_name, parent_id: nil)

    perform_enqueued_jobs(only: BackendMetricWorker) do
      BackendMetricWorker.perform_later(service.backend_id, metric.id)
    end
  end

  test '#perform for delete metric' do
    metric.delete

    ThreeScale::Core::Metric.expects(:delete).with(service.backend_id, metric.id)

    perform_enqueued_jobs(only: BackendMetricWorker) do
      BackendMetricWorker.perform_later(service.backend_id, metric.id)
    end
  end

  test 'syncs metrics with the right parent_id' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api)
    service_hits = service.metrics.hits
    service_other = FactoryBot.create(:metric, owner: service, system_name: 'other-metric-of-service')
    service_backend_id = service.backend_id


    backend_api = service.backend_apis.first
    backend_hits = backend_api.metrics.hits
    backend_other = FactoryBot.create(:method, owner: backend_api, system_name: 'other-metric-of-backend')


    worker = BackendMetricWorker.new


    metric_attributes = [
      { id: service_hits.id, name: service_hits.system_name, parent_id: nil },
      { id: service_other.id, name: service_other.system_name, parent_id: nil },
      { id: backend_hits.id, name: backend_hits.system_name, parent_id: service_hits.id },
      { id: backend_other.id, name: backend_other.system_name, parent_id: backend_hits.id }
    ]
    metric_attributes.each do |attrs|
      ThreeScale::Core::Metric.expects(:save).with(attrs.merge(service_id: service_backend_id))
      worker.perform(service_backend_id, attrs[:id])
    end
  end
end
