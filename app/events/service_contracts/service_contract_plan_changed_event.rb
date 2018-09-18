class ServiceContracts::ServiceContractPlanChangedEvent < ServicePlanRelatedEvent
  def self.create(service_contract, user)
    user ||= service_contract.account.first_admin
    provider = service_contract.provider_account

    new(
      service_contract: service_contract,
      service:          service_contract.service,
      old_plan:         service_contract.old_plan,
      new_plan:         service_contract.plan,
      provider:         provider,
      account:          service_contract.account,
      user:             user,
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
