module Backend
  module ModelExtensions
    module Metric
      def self.included(base)
        base.class_eval do
          before_destroy :cache_service_association

          # WARN: last callback is called first, gotcha!
          after_commit :sync_backend, if: ->(m) { (m.persisted? || m.destroyed?) && !m.changed? }
        end
      end

      private

      def cache_service_association
        service.account # just call it to cache it
      end

      def sync_backend
        ::BackendMetricWorker.sync(service.backend_id, id, system_name)
      end

      def sync_backend!
        ::BackendMetricWorker.new.perform(service.backend_id, id, system_name)
      end
    end
  end
end
