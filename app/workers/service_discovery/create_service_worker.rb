# frozen_string_literal: true

module ServiceDiscovery
  class CreateServiceWorker
    include Sidekiq::Worker

    def perform(account_id, cluster_namespace, cluster_service_name)
      return unless ThreeScale.config.service_discovery.enabled

      account = Account.providers.find account_id
      options = { cluster_namespace: cluster_namespace, cluster_service_name: cluster_service_name }
      ImportClusterDefinitionsService.new.create_service(account, options)
    end
  end
end
