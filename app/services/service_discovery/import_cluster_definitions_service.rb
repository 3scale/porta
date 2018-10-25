# frozen_string_literal: true

module ServiceDiscovery
  class ImportClusterDefinitionsService
    class ImportClusterDefinitionsError < StandardError; end

    def self.build_service(account, attributes = {})
      account.services.build(attributes)
    end

    def self.create_service(account, cluster_namespace:, cluster_service_name:, user: nil)
      CreateServiceWorker.perform_async(account.id, cluster_namespace, cluster_service_name, user&.id)
      build_service(account, name: cluster_service_name)
    end

    def self.refresh_service(service, user: nil)
      return unless service.discovered?
      RefreshServiceWorker.perform_async(service.id, user&.id)
    end

    attr_reader :user

    # @param user [User|NilClass] User to take the access_token. See []ServiceDiscovery::TokenRetriever]
    def initialize(user=nil)
      token_retriever = ServiceDiscovery::TokenRetriever.new(user)
      @cluster = ServiceDiscovery::ClusterClient.new bearer_token: token_retriever.access_token
    end

    attr_reader :cluster, :cluster_service

    def create_service(account, cluster_namespace:, cluster_service_name:)
      find_cluster_service_by(namespace: cluster_namespace, name: cluster_service_name)

      new_api_attributes = {
        name: cluster_service_name,
        system_name: [cluster_namespace, cluster_service_name].join('-'),
        kubernetes_service_link: cluster_service.self_link
      }
      service = self.class.build_service(account, new_api_attributes)

      return unless service.save

      import_cluster_definitions_to service
    end

    def refresh_service(service)
      service_self_link = service.kubernetes_service_link.presence || return
      find_cluster_service_by(service_self_link: service_self_link)

      import_cluster_definitions_to service
    end

    protected

    def find_cluster_service_by(criteria = {})
      service_self_link = criteria[:service_self_link].presence
      namespace, service_name = if service_self_link
                                  (service_self_link.match /\/namespaces\/(.+)\/services\/(.+)$/)&.captures
                                else
                                  criteria.values_at(:namespace, :name)
                                end

      @cluster_service = cluster.find_discoverable_service_by(namespace: namespace, name: service_name)
    end

    def import_cluster_definitions_to(service)
      import_cluster_service_endpoint_to(service)
      import_cluster_active_docs_to(service)
    end

    def import_cluster_service_endpoint_to(service)
      proxy = service.proxy
      api_backend_url = cluster_service.endpoint
      return if proxy.api_backend == api_backend_url

      unless proxy.save_and_deploy(api_backend: api_backend_url)
        log_cluster_service_import_event(service, message: 'Could not save API backend URL', details: { api_backend_url:  api_backend_url })
      end
    end

    def import_cluster_active_docs_to(service)
      return unless valid_cluster_service_spec?(service)

      api_docs_service = service.discovered_api_docs_service || build_api_doc_service(service)
      api_docs_service.skip_swagger_validations = true
      api_docs_service.body = cluster_service.specification_body

      unless api_docs_service.save
        log_cluster_service_import_event(service, message: 'Could not create ActiveDocs', details: { errors: api_docs_service.errors.full_messages })
      end
    end

    def build_api_doc_service(service)
      service.api_docs_services.build({ name: cluster_service.name, published: true, discovered: true }, without_protection: true)
    end

    def valid_cluster_service_spec?(service)
      cluster_service_spec_oas?(service) && cluster_service_spec_present?(service)
    end

    def cluster_service_spec_oas?(service)
      return true if cluster_service.specification_oas?
      log_cluster_service_import_event(service, message: 'API specification type not supported', details: { api_spec_content_type: cluster_service.specification_type })
      false
    end

    def cluster_service_spec_present?(service)
      return true if cluster_service.specification_body.present?
      log_cluster_service_import_event(service, message: 'OAS specification is empty and cannot be imported')
      false
    end

    def log_cluster_service_import_event(service, message:, details: {})
      exception = ImportClusterDefinitionsError.new(message)
      exception_details = { service_id: service.id, cluster_service: { self_link: cluster_service.self_link } }.merge(details)
      System::ErrorReporting.report_error(exception, exception_details)
    end
  end
end
