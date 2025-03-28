class Accounts::AccountCreatedEvent < AccountRelatedEvent

  def self.create(account, user)
    service_ids = account.bought_service_contracts.accessible_services.pluck(:id)

    new(
      provider: account.provider_account,
      account:  account,
      user:     user,
      service_ids:,
      metadata: {
        provider_id: account.provider_account_id
      }
    )
  end
end
