# frozen_string_literal: true

FactoryBot.define do
  factory(:payment_intent) do
    association :invoice
    sequence(:payment_intent_id) { |n| "payment-intent-id-#{n}" }
    state 'requires_action'
  end
end
