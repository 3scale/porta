class Accounts::AccountCreatedEvent < AccountRelatedEvent

  def self.create(account, user)
    new(
      provider: account.provider_account,
      account:  account,
      user:     user,
      services: account.bought_service_contracts.accessible_services.to_a,
      metadata: {
        provider_id: account.provider_account_id
      }
    )
  end
end
