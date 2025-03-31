# frozen_string_literal: true

FactoryBot.define do
  factory(:account, parent: :account_without_users) do
    after(:build) do |account|
      account.users << FactoryBot.build(:admin, account: account, state: 'active') if account.users.empty?
    end

    after(:stub) do |account|
      admin = FactoryBot.build_stubbed(:admin)

      account.stubs(:admins).returns([admin])
      admin.stubs(:account).returns(account)
    end
  end

  factory(:buyer_account, parent: :account) do
    association :provider_account

    buyer { true }

    approved
  end
end
