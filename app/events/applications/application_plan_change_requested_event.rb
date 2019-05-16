class Applications::ApplicationPlanChangeRequestedEvent < ApplicationRelatedEvent

  def self.create(application, user, requested_plan)
    new(
      application:    application,
      account:        application.account,
      user:           user,
      current_plan:   application.plan,
      service:        application.service,
      requested_plan: requested_plan,
      provider:       application.provider_account,
      metadata: {
        provider_id: application.provider_account_id
      }
    )

  end
end
