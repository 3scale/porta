# frozen_string_literal: true

module ServiceDiscovery
  class RefreshServiceWorker
    include Sidekiq::Worker

    def perform(service_id, user_id=nil)
      user = User.where(id: user_id).first
      oauth_managerriever = ServiceDiscovery::OAuthManager.new(user)

      # TODO: add more error reporting here
      return unless oauth_managerriever.service_usable?

      service = Service.find service_id
      ImportClusterDefinitionsService.new(user).refresh_service(service)
    end
  end
end
