# frozen_string_literal: true

FactoryBot.define do
  factory(:invitation) do
    email { "john@example.com" }
    account { |a| a.association(:provider_account) }

    transient do
      accepted { false }
    end

    after(:create) do |invitation, evaluator|
      invitation.accept! if evaluator.accepted
    end
  end
end
