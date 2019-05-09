class Accounts::AccountDeletedEvent < AccountRelatedEvent
  def self.create(account)
    new(
      account_id:   account.id,
      account_name: account.name,
      provider:     account.provider_account,
      buyer:        account.buyer,
      metadata: {
        provider_id: account.provider_account_id,
        user_id: User.current.try(:id)
      }
    )
  end
end
