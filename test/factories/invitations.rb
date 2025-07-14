# frozen_string_literal: true

FactoryBot.define do
  factory(:invitation) do
    sequence(:email) { |n| "john-#{n}@example.com" }
    account { |a| a.association(:provider_account) }

    transient do
      accepted { false }
    end

    after(:create) do |invitation, evaluator|
      invitation.accept! if evaluator.accepted
    end
  end
end
