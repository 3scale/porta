FactoryBot.define do
  factory :billing_strategy, :class => Finance::BillingStrategy do
    currency { 'EUR' }
  end

  factory :prepaid_billing, :parent => :billing_strategy, :class => Finance::PrepaidBillingStrategy

  factory :postpaid_billing, :parent => :billing_strategy, :class => Finance::PostpaidBillingStrategy

  factory :postpaid_with_charging, :parent => :postpaid_billing do
    charging_enabled { true }
  end
end
