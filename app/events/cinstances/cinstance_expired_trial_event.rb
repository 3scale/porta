class Cinstances::CinstanceExpiredTrialEvent < ApplicationRelatedEvent

  def self.create(cinstance)
    provider = cinstance.provider_account

    new(
      cinstance: cinstance,
      account:   cinstance.account,
      provider:  provider,
      service:   cinstance.issuer,
      plan:      cinstance.plan,
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
