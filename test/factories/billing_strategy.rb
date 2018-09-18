Factory.define :billing_strategy, :class => Finance::BillingStrategy do |s|
  s.currency 'EUR'
end

Factory.define :prepaid_billing, :parent => :billing_strategy, :class => Finance::PrepaidBillingStrategy do |s|
end

Factory.define :postpaid_billing, :parent => :billing_strategy, :class => Finance::PostpaidBillingStrategy do |s|
end

Factory.define :postpaid_with_charging, :parent => :postpaid_billing do |s|
  s.charging_enabled true
end
