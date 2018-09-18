
Given /^provider "([^\"]*)" has valid payment gateway$/ do |provider_name|
  provider_account = Account.find_by_org_name!(provider_name)
  provider_account.update_attribute(:payment_gateway_type, :bogus)
end

Given /^the provider has a deprecated payment gateway$/ do
  @provider.gateway_setting.attributes = {
    gateway_type: :authorize_net,
    gateway_settings: { login: 'foo', password: 'bar' }
  } # to prevent ActiveRecord::RecordInvalid since the payment gateway has been deprecated

  @provider.gateway_setting.save!(validate: false) # We cannot use update_columns with Oracle
end
