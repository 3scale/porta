# frozen_string_literal: true

module ServiceDiscovery
  class RefreshServiceWorker
    include Sidekiq::Worker

    def perform(service_id)
      return unless ThreeScale.config.service_discovery.enabled

      service = Service.find service_id
      ImportClusterDefinitionsService.new.refresh_service(service)
    end
  end
end
