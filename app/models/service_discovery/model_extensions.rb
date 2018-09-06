# frozen_string_literal: true

module ServiceDiscovery
  module ModelExtensions
    module Service
      def self.included(base)
        base.class_eval do
          attr_accessor :namespace
        end
      end

      def import_cluster_definitions(namespace)
        return unless ThreeScale.config.service_discovery.enabled

        # TODO: Perform async

        self.namespace = namespace

        import_cluster_service_endpoint
        import_cluster_active_docs
      rescue ServiceDiscovery::ClusterClient::ResourceNotFound
      end

      protected

      def cluster
        @cluster ||= ServiceDiscovery::ClusterClient.new
      end

      def cluster_service
        @cluster_service ||= cluster.find_discoverable_service_by(namespace: namespace, name: name)
      end

      private

      def import_cluster_service_endpoint
        proxy.save_and_deploy(api_backend: cluster_service.endpoint)
      end

      def import_cluster_active_docs
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
