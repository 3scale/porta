# frozen_string_literal: true

module Signup
  class DeveloperAccountManager < Signup::AccountManager
    self.account_builder = ->(account) do
      account.buyer = true
      account
    end

    private

    def persist!(result, plans, defaults)
      result.save!
      create_contract_plans_for_account!(result.account, plans, defaults)

      # TODO: Temporary here. A new object should have the responsability to activate and approve when needed
      # As part of THREESCALE-1317
      result.user_activate! if result.user_activate_on_minimal_or_sample_data?
    end
  end
end
