# frozen_string_literal: true

module ServiceDiscovery
  class ImportClusterServiceDefinitionsWorker
    include Sidekiq::Worker

    def perform(service_id, cluster_namespace)
      return unless ThreeScale.config.service_discovery.enabled

      api = Service.find service_id
      cluster = ServiceDiscovery::ClusterClient.new
      cluster_service = cluster.find_discoverable_service_by(name: api.name, namespace: cluster_namespace)

      api.import_cluster_service_endpoint(cluster_service)
      api.import_cluster_active_docs(cluster_service)
    end
  end
end
