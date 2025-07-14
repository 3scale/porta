module Alerts::LimitReachedCreatable
  def create(alert)
    provider = alert.cinstance.provider_account

    new(
      provider: provider,
      application_id: alert.cinstance.application_id,
      service_id:  alert.cinstance.service.id,
      level: alert.level,
      message: alert.message,
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
