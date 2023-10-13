class Applications::ApplicationCreatedEvent < ApplicationRelatedEvent
  # @param [Cinstance] application
  # @param [User] user
  def self.create(application, user)
    provider = application.provider_account
    service = application.service

    new(
      application: application,
      account:     account = application.user_account,
      provider:    provider,
      service:     service,
      plan:        application.plan,
      user:        user || account&.first_admin,
      metadata: {
        provider_id: provider&.id,
        zync: {
          service_id: service.id,
          oidc_auth_enabled: service.oauth?
        }
      }
    )
  end
end
