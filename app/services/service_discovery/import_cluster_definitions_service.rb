# frozen_string_literal: true

module ServiceDiscovery
  class ImportClusterDefinitionsService
    def self.refresh_service(service)
      return unless service.discovered?
      RefreshServiceWorker.perform_async(service.id)
    end

    def initialize
      @cluster = ServiceDiscovery::ClusterClient.new
    end

    attr_reader :cluster

    def create_service(account, cluster_namespace:, cluster_service_name:)
      cluster_service = find_cluster_service_by(namespace: cluster_namespace, name: cluster_service_name)
      new_api_attributes = {
        name: cluster_service_name,
        system_name: [cluster_namespace, cluster_service_name].join('-'),
        kubernetes_service_link: cluster_service.self_link
      }
      creation_service = ServiceCreationService.call(account, new_api_attributes)
      new_api = creation_service.service

      return unless creation_service.success? && new_api.persisted?

      new_api.import_cluster_definitions(cluster_service)
    end

    def refresh_service(service)
      service_self_link = service.kubernetes_service_link.presence || return
      cluster_service = find_cluster_service_by(service_self_link: service_self_link)
      service.import_cluster_definitions(cluster_service)
    end

    protected

    def find_cluster_service_by(criteria = {})
      service_self_link = criteria[:service_self_link].presence
      namespace, service_name = if service_self_link
                                  (service_self_link.match /\/namespaces\/(.+)\/services\/(.+)$/)&.captures
                                else
                                  criteria.values_at(:namespace, :name)
                                end

      cluster.find_discoverable_service_by(namespace: namespace, name: service_name)
    end
  end
end
