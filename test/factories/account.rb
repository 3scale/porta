# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory(:account, parent: :account_without_users) do
    trait :approved do
      state { :approved }
    end

    trait :rejected do
      state { :rejected }
    end

    trait :pending do
      state { :pending }
    end

    after(:create) do |account|
      if account.users.empty?
        FactoryBot.create(:admin, username: account.org_name.gsub(/[^a-zA-Z0-9_.]+/, '_'),
                                  account: account,
                                  state: 'active')
      end
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

    after(:build) do |account|
      # TODO: figure out why this is necessary if it's done in account :create already
      if account.users.empty?
        username = account.org_name.gsub(/[^a-zA-Z0-9_\.]+/, '_')
        account.users << FactoryBot.build(:admin, account: account, username: username, state: 'active')
      end
    end
  end
end
