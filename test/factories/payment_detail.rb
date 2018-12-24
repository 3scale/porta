FactoryBot.define(:payment_detail) do |payment_detail|
  payment_detail.sequence(:buyer_reference) { |n| "buyer-#{n}" }
  payment_detail.payment_service_reference 'a6fb0f11'
  payment_detail.credit_card_partial_number '1111'
  payment_detail.credit_card_expires_on Date.parse('2024-08-01')
end