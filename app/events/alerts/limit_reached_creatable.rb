module Alerts::LimitReachedCreatable
  def create(alert)
    provider = alert.cinstance.provider_account

    new(
      alert:    alert,
      provider: provider,
      service:  alert.cinstance.service,
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
