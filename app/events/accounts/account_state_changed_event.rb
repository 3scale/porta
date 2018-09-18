class Accounts::AccountStateChangedEvent < AccountRelatedEvent

  def self.create(account, previous_state)
    new(
      account:        account,
      state:          account.state,
      previous_state: previous_state,
      provider:       account.provider_account,
      metadata: {
        provider_id: account.provider_account_id
      }
    )
  end
end
