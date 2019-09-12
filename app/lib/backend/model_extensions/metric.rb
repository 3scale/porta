module Backend
  module ModelExtensions
    module Metric
      def self.included(base)
        base.class_eval do
          before_destroy :cache_service_association

          # WARN: last callback is called first, gotcha!

          # These specific conditions can lead to multiple #sync_backend calls under race condition
          # - 2 threads are trying to destroy a metric – T1 and T2
          # - T1 succeeds and T2 gets `persisted? => false` inside `ActiveRecord::Persistence#destroy` due to https://apidock.com/rails/v4.2.7/ActiveRecord/Core/sync_with_transaction_state, thus making `@_trigger_destroy_callback = true`
          # - Because of `m.destroyed? == true`, both T1 and T2 will invoke the callback
          after_commit :sync_backend, if: ->(m) { (m.persisted? || m.destroyed?) && !m.changed? }
        end
      end

      private

      def cache_service_association
        owner.account # just call it to cache it
      end

      def sync_backend
        execute_per_service do |service|
          ::BackendMetricWorker.perform_async(*args_to_backend_metric_worker(service))
        end
      end

      def sync_backend!
        execute_per_service do |service|
          ::BackendMetricWorker.new.perform(*args_to_backend_metric_worker(service))
        end
      end

      def execute_per_service(&block)
        services = [*owner.try(:services), service].compact
        services.each(&block)
      end

      def args_to_backend_metric_worker(service)
        [service.backend_id, id, system_name, parent_id_for_service(service)]
      end

      def parent_id_for_service(service)
        if backend_api_metric? && hits?
          service.metrics.hits&.id
        else
          parent_id
        end
      end
    end
  end
end
