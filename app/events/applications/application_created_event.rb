class Applications::ApplicationCreatedEvent < ApplicationRelatedEvent
  # @param [Cinstance] application
  # @param [User] user
  def self.create(application, user)
    provider = application.provider_account
    service = application.service || Service.new({id: application.service_id}, without_protection: true)

    new(
      application: application,
      account:     account = application.user_account,
      provider:    provider,
      # this really can't be application.service as it would break:
      # $ rspec ./spec/acceptance/api/application_spec.rb -e 'Cinstance application json format GET /admin/api/applications/find.:format with app id Get Application'
      service:     application.plan.issuer,
      plan:        application.plan,
      user:        user || account.try!(:first_admin),
      metadata: {
        provider_id: provider.try!(:id),
        zync: {
          service_id: service.id,
          service_backend_version: service.backend_version.to_s
        }
      }
    )
  end
end
