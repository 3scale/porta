# frozen_string_literal: true

module ServiceDiscovery
  class ImportClusterServiceDefinitionsWorker
    include Sidekiq::Worker

    def perform(account_id, cluster_namespace, service_name)
      return unless ThreeScale.config.service_discovery.enabled

      account = Account.providers.find account_id
      service_system_name = [cluster_namespace, service_name].join('-')

      cluster = ServiceDiscovery::ClusterClient.new
      cluster_service = cluster.find_discoverable_service_by(name: service_name,
                                                             namespace: cluster_namespace)

      service_creation = ServiceCreationService.call(account, name: service_name,
                                                              system_name: service_system_name,
                                                              kubernetes_service_link: cluster_service.self_link)
      new_api = service_creation.service

      return unless service_creation.success? && new_api.persisted?

      new_api.import_cluster_service_endpoint(cluster_service)
      new_api.import_cluster_active_docs(cluster_service)
    end
  end
end
