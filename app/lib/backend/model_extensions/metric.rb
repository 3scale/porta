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

      def sync_backend
        execute_per_service do |service|
          sync_backend_for_service(service)
        end
      end

      def sync_backend!
        execute_per_service do |service|
          sync_backend_for_service!(service)
        end
      end

      def sync_backend_for_service(service)
        ::BackendMetricWorker.perform_async(service.backend_id, id, attributes['system_name'])
      end

      def sync_backend_for_service!(service)
        ::BackendMetricWorker.new.perform(service.backend_id, id, attributes['system_name'])
      end

      private

      def cache_service_association
        owner.account # just call it to cache it
      end

      def execute_per_service(&block)
        services = [*owner.try(:services), service].compact
        services.each(&block)
      end
    end
  end
end
