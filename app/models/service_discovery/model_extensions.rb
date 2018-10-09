# frozen_string_literal: true

module ServiceDiscovery
  module ModelExtensions
    module Service
      class ImportClusterDefinitionsError < StandardError; end

      def self.included(base)
        base.class_eval do
          attr_accessor :source
          attr_accessor :namespace
        end
      end

      def import_cluster_service_endpoint(cluster_service)
        api_backend_url = cluster_service.endpoint

        unless proxy.save_and_deploy(api_backend: api_backend_url)
          log_cluster_service_import_event(cluster_service, message: 'Could not save API backend URL',
                                                            details: { api_backend_url:  api_backend_url })
        end
      end

      def import_cluster_active_docs(cluster_service)
        unless cluster_service.oas?
          log_cluster_service_import_event(cluster_service, message: 'API specification type not supported',
                                                            details: { api_spec_content_type: cluster_service.specification_type })
          return
        end

        if (spec_content = cluster_service.specification).blank?
          log_cluster_service_import_event(cluster_service, message: 'OAS specification is empty and cannot be imported')
          return
        end

        api_docs_service = api_docs_services.build(name: cluster_service.name,
                                                   body: spec_content,
                                                   published: true,
                                                   skip_swagger_validations: true)

        unless api_docs_service.save
          log_cluster_service_import_event(cluster_service, message: 'Could not create ActiveDocs',
                                                            details: { errors: api_docs_service.errors.full_messages })
        end
      end

      protected

      def log_cluster_service_import_event(cluster_service, message:, details: {})
        exception = ImportClusterDefinitionsError.new(message)
        exception_details = { service_id: id, cluster_service: { self_link: cluster_service.self_link } }.merge(details)
        System::ErrorReporting.report_error(exception, exception_details)
      end
    end
  end
end
