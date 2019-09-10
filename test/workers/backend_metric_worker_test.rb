# frozen_string_literal: true

require 'test_helper'

class BackendMetricWorkerTest < ActiveSupport::TestCase

  def teardown
    clear_sidekiq_lock
  end

  test 'lock_workers should return service and metric_name' do
    assert_equal 'service:1/metric:42', BackendMetricWorker.lock_workers(1, 42, 'lol')
  end

  test 'update metric' do
    metric = FactoryBot.create(:metric, system_name: 'some_system_name')
    service = metric.service

    ThreeScale::Core::Metric.expects(:save).with(id: metric.id, service_id: service.backend_id,
                                                 name: 'some_system_name', parent_id: nil)

    BackendMetricWorker.new.perform(service.backend_id, metric.id, metric.system_name)
  end

  test 'destroy metric' do
    ThreeScale::Core::Metric.expects(:delete).with('foo', 'bar')
    BackendMetricWorker.new.perform('foo', 'bar', 'lol')
  end

  test 'concurrent job is retried if locked on same service and metric' do
    args = ['foo', 'bar']
    lock = set_sidekiq_lock(BackendMetricWorker, args)
    lock.expects(:acquire!).returns(false)
    worker = BackendMetricWorker.new
    worker.expects(:retry_job).with(*args)
    worker.perform(*args)
  end

  test '#retry_job reenqueues the job' do
    args = ['foo', 'bar']
    worker = BackendMetricWorker.new
    BackendMetricWorker.expects(:perform_async).with(*args)
    worker.send(:retry_job, *args)
  end

  test '#retry_job raises LockError if last attempt' do
    args = ['foo', 'bar']
    worker = BackendMetricWorker.new
    worker.expects(:last_attempt?).returns(true)
    BackendMetricWorker.expects(:perform_async).with(*args).never
    assert_raises(BackendMetricWorker::LockError) { worker.send(:retry_job, *args) }
  end

  test 'can force a given parent_id' do
    metric = FactoryBot.create(:metric, system_name: 'some_system_name')
    service_backend_id = metric.service.backend_id
    metric_id = metric.id
    metric_system_name = metric.system_name

    worker = BackendMetricWorker.new

    ThreeScale::Core::Metric.expects(:save).with(service_id: service_backend_id, id: metric_id, name: metric_system_name, parent_id: nil)
    worker.perform(service_backend_id, metric_id, metric_system_name)

    ThreeScale::Core::Metric.expects(:save).with(service_id: service_backend_id, id: metric_id, name: metric_system_name, parent_id: 123)
    worker.perform(service_backend_id, metric_id, metric_system_name, 123)
  end
end
