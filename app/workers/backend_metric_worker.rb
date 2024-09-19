# frozen_string_literal: true

class BackendMetricWorker < ApplicationJob
  include Sidekiq::Throttled::Job

  queue_as :backend_sync

  sidekiq_throttle concurrency: {
                       limit: 1,
                       key_suffix: ->(service_id, metric_id, *) { "service:#{service_id}/metric:#{metric_id}" },
                       ttl: 1.hour.to_i
                     }

  def perform(service_backend_id, metric_id)
    metric = Metric.find_by(id: metric_id)
    service = Service.find_by(id: service_backend_id)
    if metric && service
      new_metric_attributes = {
        service_id: service_backend_id,
        id: metric_id,
        name: metric.system_name,
        parent_id: metric.parent_id_for_service(service)
      }
      ThreeScale::Core::Metric.save(new_metric_attributes)
    else
      ThreeScale::Core::Metric.delete(service_backend_id, metric_id)
    end
  end
end
