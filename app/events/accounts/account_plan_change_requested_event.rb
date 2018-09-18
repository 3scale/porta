class Accounts::AccountPlanChangeRequestedEvent < AccountRelatedEvent

  def self.create(account, user, requested_plan)
    new(
      account:        account,
      user:           user,
      current_plan:   user.account.bought_account_plan,
      requested_plan: requested_plan,
      provider:       account.provider_account,
      metadata: {
        provider_id: account.provider_account_id
      }
    )
  end
end
