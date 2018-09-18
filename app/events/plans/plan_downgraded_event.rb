class Plans::PlanDowngradedEvent < BillingRelatedEvent
  def self.create(new_plan, old_plan, contract)
    provider = new_plan.provider_account

    new(
      new_plan: new_plan,
      old_plan: old_plan,
      provider: provider,
      service:  new_plan.issuer,
      account:  contract.account,
      contract: contract,
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
