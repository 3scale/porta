class ServiceContracts::ServiceContractCreatedEvent < ServicePlanRelatedEvent
  def self.create(service_contract, user)
    provider = service_contract.provider_account

    new(
      service_contract: service_contract,
      service:          service_contract.service,
      plan:             service_contract.plan,
      provider:         provider,
      account:          account = service_contract.buyer_account,
      user:             user || account.try!(:first_admin),
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
