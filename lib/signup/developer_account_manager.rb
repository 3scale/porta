# frozen_string_literal: true

class Signup::DeveloperAccountManager < Signup::AccountManager
  self.account_builder = lambda do |account|
    account.buyer = true
    account
  end

  private

  def persist!(result, plans, defaults)
    result.save!
    create_contract_plans_for_account!(result.account, plans, defaults)
    result.user_activate! if result.user_activate_on_minimal_signup? # TODO: Temporary here. A new object should have the responsability to activate and approve when needed
  end
end
