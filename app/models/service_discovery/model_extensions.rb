# frozen_string_literal: true

module ServiceDiscovery
  module ModelExtensions
    module Service
      def self.included(base)
        base.class_eval do
          attr_accessor :source
          attr_accessor :namespace
        end
      end

      def import_cluster_service_endpoint(cluster_service)
        proxy.save_and_deploy(api_backend: cluster_service.endpoint)
      end

      def import_cluster_active_docs(cluster_service)
        cluster_service_id = cluster_service.self_link
        logger = Rails.logger

        unless cluster_service.oas?
          logger.info("API specification type for #{cluster_service_id} is not supported. Content-Type: #{cluster_service.specification_type}")
          return
        end

        if (spec_content = cluster_service.specification).blank?
          logger.info("OAS specification for #{cluster_service_id} is empty and cannot be imported")
          return
        end

        provider.api_docs_services.create({ name: cluster_service.name,
                                            body: spec_content,
                                            published: true,
                                            skip_swagger_validations: true })
      end
    end
  end
end
