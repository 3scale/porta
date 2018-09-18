class Services::ServicePlanChangeRequestedEvent < ServicePlanRelatedEvent

  def self.create(service_contract, user, requested_plan)
    account = service_contract.user_account
    new(
      service:        service_contract.service,
      account:        account,
      user:           user,
      current_plan:   service_contract.service_plan,
      requested_plan: requested_plan,
      provider:       account.provider_account,
      metadata: {
        provider_id:  account.provider_account_id
      }
    )
  end
end
