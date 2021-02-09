# frozen_string_literal: true

FactoryBot.define do
  factory(:payment_intent) do
    association :invoice
    sequence(:reference) { |n| "payment-intent-#{n}" }
    state { 'requires_action' }
  end
end
