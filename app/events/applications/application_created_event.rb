# frozen_string_literal: true

class Applications::ApplicationCreatedEvent < ApplicationRelatedEvent
  # @param [Cinstance] application
  # @param [User] user
  def self.create(application, user)
    provider = application.provider_account

    new(
      application: application,
      account:     account = application.user_account,
      provider:    provider,
      service:     application.service,
      plan:        application.plan,
      user:        user || account&.first_admin,
      metadata: {
        provider_id: provider&.id,
        zync: {
          service_id: application.service_id
        }
      }
    )
  end
end
