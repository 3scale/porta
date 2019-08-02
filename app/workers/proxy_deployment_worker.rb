class ProxyDeploymentWorker
  include Sidekiq::Worker

  def perform(deployment_id, user_id, proxy_id)
    user = User.find(user_id)
    provider = user.account
    proxy = provider.proxies.find(proxy_id)
    analytics = ThreeScale::Analytics.user_tracking(user)

    deployment = ::ProviderProxyDeploymentService.new(provider)


    MessageBus.with_site_id(provider.id) do |message_bus|
      Rails.logger.info "Publishing '/apicast/deploy' status pending (#{deployment_id}) user: #{user.id}"
      message_bus.publish('/apicast/deploy',
                          { id: deployment_id, status: :pending }, user_ids: [ user.id ])

      deployed = deployment.deploy(proxy)

      message_bus.publish('/apicast/deploy',
                         { id: deployment_id, result: deployed, status: :done }, user_ids: [ user.id ])
      Rails.logger.info "Publishing '/apicast/deploy' result #{deployed} (#{deployment_id}) user: #{user.id}"
      analytics.track('Sandbox Proxy Deploy', success: deployed, errors: proxy.errors[:sandbox_endpoint], id: deployment_id)

      if deployed
        if (api_test_result = proxy.send_api_test_request!)
          if ApiClassificationService.test(proxy.api_backend).real_api?
            provider.onboarding.bubble_update('api')
          end
        end

        message_bus.publish('/apicast/test',
                            { id: deployment_id, test: api_test_result, errors: proxy.errors },
                            user_ids: [ user.id ])
        Rails.logger.info "Publishing '/apicast/test' result #{api_test_result} (#{deployment_id}) user: #{user.id}"
      else
        message_bus.publish('/apicast/test',
                            { id: deployment_id, status: :skipped },
                            user_ids: [ user.id ])
      end
    end
  end
end
