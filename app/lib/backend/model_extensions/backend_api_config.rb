# frozen_string_literal: true
module Backend
  module ModelExtensions
    module BackendApiConfig
      extend ActiveSupport::Concern

      included do
        after_commit :sync_backend_api_metrics_with_backend, on: :create
      end

      def sync_backend_api_metrics_with_backend
        backend_api.services.reset
        backend_api.metrics.each { |metric| metric.send(:sync_backend) }
      end
    end
  end
end
