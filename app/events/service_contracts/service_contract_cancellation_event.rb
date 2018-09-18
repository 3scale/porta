class ServiceContracts::ServiceContractCancellationEvent < ServicePlanRelatedEvent

  class << self

    def create(contract)
      plan     = contract.plan
      service  = contract.issuer
      account  = contract.buyer_account
      provider = contract.provider_account || account.try!(:provider_account)

      new(
        plan_name:    plan.name,
        service_name: service.name,
        plan_id:      contract.plan_id,
        service:      service,
        provider:     provider,
        account_id:   account.id,
        account_name: account.name,
        metadata: {
          provider_id: provider.try!(:id) || contract.tenant_id
        }
      )
    end

    def valid?(contract)
      return false if contract.try!(:destroyed_by_association)

      contract && contract.plan && contract.issuer && contract.buyer_account
    end
  end
end
