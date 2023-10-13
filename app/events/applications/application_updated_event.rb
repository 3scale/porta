# frozen_string_literal: true

class Applications::ApplicationUpdatedEvent < ApplicationRelatedEvent

  # @param [Cinstance] application
  def self.create(application)
    provider = application.provider_account || Account.new
    service = application.service

    new(
      application: application,
      metadata: {
        provider_id: provider.id,
        zync: {
          service_id: service.id,
          oidc_auth_enabled: service.oauth?
        }
      }
    )
  end
end
