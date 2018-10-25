# TODO: - DRY all these steps
Given /^a provider "([^\"]*)" with (postpaid|prepaid)?\s*billing (enabled|disabled)?$/ do |provider_name,mode,status|
  step %(a provider "#{provider_name}")
  mode = nil if mode == 'postpaid'
  step %(provider "#{provider_name}" has #{mode} billing #{status})
end

Given /^a provider "([^\"]*)" with charging enabled$/ do |provider_name|
  step %(a provider "#{provider_name}" with billing enabled)
  step %(provider "#{provider_name}" is charging)
end

Given /^(provider "[^\"]*") is (not )?charging$/ do |provider,not_charging|
  unless provider.billing_strategy
    provider.billing_strategy = Factory(:postpaid_billing)
    provider.save!
  end

  if not_charging.nil?
    provider.payment_gateway_type = :bogus
    provider.payment_gateway_options = {:login => 'foo', :password => 'bar', :user => 'user', :merchant_id => '123', :public_key => 'key', :private_key => 'priv key'}
  end

  provider.billing_strategy.charging_enabled = not_charging.nil?
  provider.billing_strategy.currency = 'EUR'
  provider.billing_strategy.save!
  provider.save!
end

Given(/^the provider is (not )?charging$/) do |not_charging|
  step %(provider "#{@provider.domain}" is #{not_charging}charging)
end

Given /^(provider "[^\"]*") is fake charging$/ do |provider|
  provider.settings.allow_finance! unless provider.settings.finance.allowed?

  unless provider.billing_strategy
    provider.billing_strategy = Factory(:postpaid_billing, :account => provider)
    provider.save!
  end

  provider.payment_gateway_type = :bogus
  provider.billing_strategy.charging_enabled = true
  provider.billing_strategy.currency = 'EUR'
  provider.billing_strategy.save!
  provider.save!
end

Given /^(provider "[^\"]*") has ?(prepaid|postpaid)? billing (enabled|disabled)$/ do |provider,mode,status|
  if status.to_sym == :enabled
    provider.settings.allow_finance! unless provider.settings.finance.allowed?

    type = if (mode && mode.strip == 'prepaid')
             'Finance::PrepaidBillingStrategy'
           else
             'Finance::PostpaidBillingStrategy'
           end

    provider.billing_strategy.update_attribute(:currency, 'EUR')
    provider.billing_strategy.change_mode(type)
  else
    provider.settings.deny_finance! unless provider.settings.finance.denied?
  end
end

Given /^the provider has (prepaid|postpaid) billing enabled/ do |mode|
  step %(provider "#{@provider.name}" has #{mode} billing enabled)
end


Given /^(provider ".+?") doesn't have billing address$/ do |provider| #'
  %w[zip name city state country phone address1].each do |attr|
    provider.send("billing_address_#{attr}=", nil)
  end
  provider.save!
end

Given /^master is( not)? billing tenants$/ do |master_billing_disabled|
  ThreeScale.stubs(master_billing_enabled?: !master_billing_disabled)
end
