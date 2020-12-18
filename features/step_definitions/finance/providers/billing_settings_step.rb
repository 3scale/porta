# frozen_string_literal: true

# TODO: - DRY all these steps
# TODO: convert this to cucumber expression
Given /^a provider "([^\"]*)" with (postpaid|prepaid)?\s*billing (enabled|disabled)?$/ do |provider_name, mode, status|
  step %(a provider "#{provider_name}")
  mode = nil if mode == 'postpaid'
  step %(provider "#{provider_name}" has #{mode} billing #{status ? 'enabled' : 'disabled'}).squish
end

Given "a provider {string} with charging enabled" do |provider_name|
  step %(a provider "#{provider_name}" with billing enabled)
  step %(provider "#{provider_name}" is charging)
end

Given "{provider} {is} charging" do |provider, charging_enabled|
  unless provider.billing_strategy
    provider.billing_strategy = FactoryBot.create(:postpaid_billing)
    provider.save!
  end

  if charging_enabled
    provider.payment_gateway_type = :bogus
    provider.payment_gateway_options = { login: 'foo',
                                         password: 'bar',
                                         user: 'user',
                                         merchant_id: '123',
                                         public_key: 'key',
                                         private_key: 'priv key' }
  end

  provider.billing_strategy.charging_enabled = charging_enabled
  provider.billing_strategy.currency = 'EUR'
  provider.billing_strategy.save!
  provider.save!
end

Given "the provider {is} charging" do |is|
  step %(provider "#{@provider.domain}" #{is ? 'is' : 'is not'} charging)
end

Given "{provider} is fake charging" do |provider|
  provider.settings.allow_finance! unless provider.settings.finance.allowed?

  unless provider.billing_strategy
    provider.billing_strategy = FactoryBot.create(:postpaid_billing, account: provider)
    provider.save!
  end

  provider.payment_gateway_type = :bogus
  provider.billing_strategy.charging_enabled = true
  provider.billing_strategy.currency = 'EUR'
  provider.billing_strategy.save!
  provider.save!
end

# Given /^(provider "[^\"]*") has ?(prepaid|postpaid)? billing (enabled|disabled)$/ do |provider,mode,status|
Given "{provider} has {billing} {enabled}" do |provider, mode, enabled|
  if enabled
    provider.settings.allow_finance! unless provider.settings.finance.allowed?
    provider.billing_strategy.update!(currency: 'EUR')
    provider.billing_strategy.change_mode(mode)
  else
    provider.settings.deny_finance! unless provider.settings.finance.denied?
  end
end

Given "the provider has (word) billing enabled" do |mode|
  step %(provider "#{@provider.name}" has #{mode} billing enabled)
end

Given "{provider} doesn't have billing address" do |provider|
  %w[zip name city state country phone address1].each do |attr|
    provider.send("billing_address_#{attr}=", nil)
  end
  provider.save!
end

Given "master {is} billing tenants" do |master_billing_enabled|
  ThreeScale.stubs(master_billing_enabled?: master_billing_enabled)
end
