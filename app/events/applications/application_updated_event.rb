# frozen_string_literal: true

class Applications::ApplicationUpdatedEvent < ApplicationRelatedEvent

  # @param [Cinstance] application
  def self.create(application)
    provider = application.provider_account || Account.new
    service = application.service || Service.new({id: application.service_id}, without_protection: true)

    new(
      application: application,
      metadata: {
        provider_id: provider.id,
        zync: {
          service_id: service.id,
          service_backend_version: service.backend_version.to_s
        }
      }
    )
  end
end
