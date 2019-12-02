# frozen_string_literal: true

class BackendMetricWorker
  class LockError < StandardError; end

  include Sidekiq::Worker
  include ThreeScale::SidekiqLockWorker
  include ThreeScale::SidekiqRetrySupport::Worker

  sidekiq_options queue: :backend_sync,
                  retry: 3,
                  lock: {
                    timeout: 1.hour.in_milliseconds,
                    name: proc { |*args| BackendMetricWorker.lock_workers(*args) }
                  }
  sidekiq_retry_in do |_count|
    5.minutes.to_i
  end

  def self.lock_workers(service_id, metric_id, *)
    "service:#{service_id}/metric:#{metric_id}"
  end

  def perform(backend_id, metric_id, *args)
    retry_job(backend_id, metric_id, *args) unless lock(backend_id, metric_id).acquire!

    begin
      save_or_delete_metric(backend_id, metric_id)
    ensure
      lock.release!
    end
  end

  protected

  def retry_job(backend_id, metric_id, *args)
    raise LockError if last_attempt?
    self.class.perform_async(backend_id, metric_id, *args)
  end

  def save_or_delete_metric(service_backend_id, metric_id)
    metric = Metric.find_by(id: metric_id)
    service = Service.find_by(id: service_backend_id)
    if metric && service
      new_metric_attributes = {
        service_id: service_backend_id,
        id: metric_id,
        name: metric.extended_system_name,
        parent_id: metric.parent_id_for_service(service)
      }
      ThreeScale::Core::Metric.save(new_metric_attributes)
    else
      ThreeScale::Core::Metric.delete(service_backend_id, metric_id)
    end
  end
end
