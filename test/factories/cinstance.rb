# frozen_string_literal: true

FactoryBot.define do
  factory(:contract) do
    association :user_account, :factory => :pending_buyer_account

    after(:stub) do |cinstance|
      cinstance.created_at = 2.months.ago
      cinstance.state = 'live'
      cinstance.user_key ||= SecureRandom.hex(16)
      cinstance.provider_public_key ||= SecureRandom.hex(32)

      cinstance.stubs(:keys).returns([])
      cinstance.stubs(:access_rules).returns([])
    end

    after(:build) do |contract|
      if contract.plan && contract.user_account && contract.user_account.provider_account.nil?
        contract.plan.provider_account.buyer_accounts << contract.user_account
      end
    end
  end

  factory(:cinstance, :aliases => %i[application application_contract], :parent => :contract, :class => Cinstance) do
    association :plan, :factory => :application_plan

    trait :as_pending do
      plan { FactoryBot.create(:application_plan, approval_required: true) }
    end

    trait :with_default_plan do
      plan { service.default_application_plan }
    end
  end

  factory(:account_contract, :parent => :contract, :class => AccountContract) do
    association :plan, :factory => :account_plan
  end

  factory(:service_contract, :parent => :contract, :class => ServiceContract) do
    association :plan, :factory => :service_plan
  end

  factory(:application_key) do
    association :application, :factory => :cinstance
    sequence(:value) { |n| "app-key-#{n}" }
  end

  factory(:referrer_filter) do
    association :application, :factory => :cinstance
    sequence(:value) { |n| "#{n}.domain.example.com" }
  end
end
