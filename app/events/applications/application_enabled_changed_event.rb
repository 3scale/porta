# frozen_string_literal: true

class Applications::ApplicationEnabledChangedEvent < ApplicationRelatedEvent

  class << self
    def create(application)
      provider = application.provider_account || Account.new
      service = application.service

      new(
        application: application,
        service: service,
        metadata: {
          provider_id: provider.id,
          zync: {
            service_id: service.id
          }
        }
      )
    end

    def valid?(application)
      application.is_a? Cinstance
    end
  end
end
