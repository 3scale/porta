# frozen_string_literal: true

FactoryBot.define do
  factory(:contract) do
    user_account {
      provider_account = @overrides[:plan]&.provider_account
      if provider_account
        provider_account&.buyer_accounts&.first || association(:buyer_account, provider_account: provider_account)
      else
        association(:buyer_account)
      end
    }

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
    plan { association :application_plan, issuer: user_account.provider_account.default_service }

    sequence(:name) { |n| "Cinstance #{n + Time.now.to_i}" }

    trait :as_pending do
      plan { FactoryBot.create(:application_plan, approval_required: true) }
    end

    after(:build) do |cinstance|
      unless cinstance.plan.issuer_id
        # provider#create_first_service is called only in after_create so we may end up with a nil issuer for the plan
        cinstance.plan.issuer = FactoryBot.build(:service, account: cinstance.user_account.provider_account)
      end
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
