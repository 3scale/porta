class Accounts::ExpiredCreditCardProviderEvent < BillingRelatedEvent

  def self.create(account)
    new(
      account:  account,
      provider: account.provider_account,
      metadata: {
        provider_id: account.provider_account_id
      }
    )
  end
end
