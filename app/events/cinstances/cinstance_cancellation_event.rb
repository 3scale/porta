class Cinstances::CinstanceCancellationEvent < ApplicationRelatedEvent

  class << self

    def create(cinstance)
      plan     = cinstance.plan
      service  = cinstance.issuer
      account  = cinstance.account || Account.new
      provider = cinstance.provider_account || account.provider_account || Account.new

      new(
        id:             cinstance.id,
        tenant_id:      tenant_id = cinstance.tenant_id,
        cinstance_name: cinstance.name,
        plan_name:      plan.name,
        plan_id:        cinstance.plan_id,
        service_name:   service.name,
        account_name:   account.name,
        provider:       provider,
        service:        service,
        metadata: {
          provider_id: provider.id || tenant_id
        }
      )
    end

    def valid?(cinstance)
      return false unless cinstance
      return false if cinstance.destroyed_by_association

      cinstance.issuer && cinstance.plan && cinstance.account
    end
  end
end
