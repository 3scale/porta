# frozen_string_literal: true

module ServiceDiscovery
  class CreateServiceWorker
    include Sidekiq::Worker

    def perform(account_id, cluster_namespace, cluster_service_name, user_id=nil)
      user = User.where(id: user_id).first
      oauth_manager = ServiceDiscovery::OAuthManager.new(user)

      # TODO: add more error reporting here
      return unless oauth_manager.service_usable?
      account = Account.providers.find account_id
      options = { cluster_namespace: cluster_namespace, cluster_service_name: cluster_service_name }
      ImportClusterDefinitionsService.new(user).create_service(account, options)
    end
  end
end
