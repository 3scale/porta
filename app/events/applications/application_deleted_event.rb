# frozen_string_literal: true

class Applications::ApplicationDeletedEvent < ApplicationRelatedEvent

  # @param [Cinstance] application
  def self.create(application)
    new(
      application: MissingModel::MissingApplication.new(id: application.id),
      metadata: {
        provider_id: application.provider_account_id || application.tenant_id,
        zync: {
          service_id: application.service_id
        }
      }
    )
  end
end
