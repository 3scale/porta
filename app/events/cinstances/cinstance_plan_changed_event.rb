class Cinstances::CinstancePlanChangedEvent < ApplicationRelatedEvent
  def self.create(cinstance, user)
    new(
      cinstance: cinstance,
      service:   cinstance.service,
      old_plan:  cinstance.old_plan,
      new_plan:  cinstance.plan,
      account:   cinstance.account,
      provider:  provider = cinstance.provider_account,
      user:      user || cinstance.account.first_admin,
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
