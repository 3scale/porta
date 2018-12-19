# frozen_string_literal: true

class Applications::ApplicationDeletedEvent < ApplicationRelatedEvent

  # @param [Cinstance] application
  def self.create(application)
    new(
      application: MissingModel::MissingApplication.new(id: application.id),
      metadata: {
        provider_id: application.provider_account.try(:id) || application.tenant_id, # TODO: I don't know why but the provider_account_id is not the same as provider_account.id
        zync: {
          service_id: application.service_id,
          proxy_id: application.service.proxy.id # TODO: It could not exist anymore!
        }
      }
    )
  end
end
