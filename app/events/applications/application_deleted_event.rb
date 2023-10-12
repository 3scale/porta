# frozen_string_literal: true

class Applications::ApplicationDeletedEvent < ApplicationRelatedEvent

  # @param [Cinstance] application
  # :reek:NilCheck but proxy can be nil at this point
  def self.create(application)
    service = application.service || Service.new({id: application.service_id}, without_protection: true)
    new(
      application: MissingModel::MissingApplication.new(id: application.id),
      service_backend_id: service.backend_id,
      application_id: application.application_id,
      metadata: {
        provider_id: application.provider_account_id || application.tenant_id,
        zync: {
          service_id: service.id,
          proxy_id: service.proxy&.id,
          service_backend_version: service.backend_version.to_s
        }
      }
    )
  end
end
