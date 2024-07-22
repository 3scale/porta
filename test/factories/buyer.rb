# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  # FIXME: buyer accounts without provider accounts, is that ok?
  factory(:buyer_account_with_pending_user, parent: :account) do
    buyer { true }
  end

  factory(:pending_buyer_account, parent: :pending_account) do
    buyer { true }

    after(:create) do |buyer|
      account_plan = buyer.provider_account.account_plans.default
      buyer.buy! account_plan
    end
  end

  factory(:rejected_buyer_account, parent: :rejected_account) do
    buyer { true }

    after(:create) do |buyer|
      account_plan = buyer.provider_account.account_plans.default
      buyer.buy! account_plan
    end
  end

  factory(:buyer_account, parent: :pending_buyer_account) do
    association :provider_account

    after(:create) do |account|
      account.users.each do |user|
        user.activate! unless user.active? # horrible horrible factories
      end

      account.approve! if account.can_approve?
    end

    after(:build) do |account|
      if account.users.empty?
        username = account.org_name.gsub(/[^a-zA-Z0-9_.]+/, '_')
        account.users << FactoryBot.build(:admin, account: account, username: username)
      end
    end
  end

  factory(:buyer_account_without_billing_address, parent: :buyer_account) do
    after(:create) do |account|
      account.billing_address_name = nil
      account.billing_address_address1 = nil
      account.billing_address_address2 = nil
      account.billing_address_city = nil
      account.billing_address_country = nil
      account.save!
    end
  end
end
