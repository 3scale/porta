# frozen_string_literal: true

module ServiceDiscovery
  module ModelExtensions
    module Service
      def self.included(base)
        base.class_eval do
          attr_accessor :discovered
          attr_accessor :cluster_namespace

          after_commit :import_cluster_definitions, on: :create
        end
      end

      def import_cluster_definitions
        return unless discovered
        ImportClusterServiceDefinitionsWorker.perform_async(self.id, cluster_namespace)
      end

      def import_cluster_service_endpoint(cluster_service)
        proxy.save_and_deploy(api_backend: cluster_service.endpoint)
      end

      def import_cluster_active_docs(cluster_service)
        return unless cluster_service.oas?

        spec_content = cluster_service.specification
        return if spec_content.blank?

        provider.api_docs_services.create({ name: cluster_service.name,
                                            body: spec_content,
                                            published: true,
                                            skip_swagger_validations: true })
      end
    end
  end
end
