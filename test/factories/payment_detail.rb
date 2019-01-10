FactoryBot.define do
  factory(:payment_detail) do
    sequence(:buyer_reference) { |n| "buyer-#{n}" }
    payment_service_reference { 'a6fb0f11' }
    credit_card_partial_number { '1111' }
    credit_card_expires_on { Date.parse('2024-08-01') }
  end
end
