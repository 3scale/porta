# frozen_string_literal: true

class BackendMetricWorker
  class LockError < StandardError; end

  include Sidekiq::Worker
  include ThreeScale::SidekiqLockWorker

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

  def self.sync(backend_id, metric_id, metric_system_name)
    perform_async(backend_id, metric_id, metric_system_name)
  end

  def perform(backend_id, metric_id, *)
    raise LockError unless lock(backend_id, metric_id).acquire!

    begin
      if (metric = Metric.find_by(id: metric_id))

        ThreeScale::Core::Metric.save(service_id: backend_id,
                                      id: metric_id,
                                      name: metric.system_name,
                                      parent_id: metric.parent_id)
      else
        ThreeScale::Core::Metric.delete(backend_id, metric_id)
      end
    ensure
      lock.release!
    end
  end
end
