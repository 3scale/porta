# frozen_string_literal: true

FactoryBot.define do
  factory(:sso_token) do
    account { :simple_provider }
    user_id { account.buyer_accounts.last.users.first.id }
  end
end
