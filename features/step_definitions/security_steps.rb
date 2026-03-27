# frozen_string_literal: true

Given('the provider has admin portal Permissions-Policy {string}') do |policy_value|
  @provider.account_settings.create!(
    type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
    value: policy_value
  )
end

Given('the provider has developer portal Permissions-Policy {string}') do |policy_value|
  @provider.account_settings.create!(
    type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
    value: policy_value
  )
end

When('I visit the provider security settings page') do
  visit edit_provider_admin_account_security_path
end

When('I visit the developer portal security settings page') do
  visit edit_admin_site_security_path
end

Then('the admin portal should have Permissions-Policy header {string}') do |expected_value|
  visit edit_provider_admin_bot_protection_path
  assert_equal expected_value, page.response_headers['Permissions-Policy']
end

Then('the admin portal should not have Permissions-Policy header') do
  visit edit_provider_admin_bot_protection_path
  assert_nil page.response_headers['Permissions-Policy']
end

Then('the developer portal should have Permissions-Policy header {string}') do |expected_value|
  # Visit a developer portal page to check the header
  buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
  user = FactoryBot.create(:user, account: buyer)
  login_as(user)
  visit admin_dashboard_path
  assert_equal expected_value, page.response_headers['Permissions-Policy']
end

Then('the developer portal should not have Permissions-Policy header') do
  buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
  user = FactoryBot.create(:user, account: buyer)
  login_as(user)
  visit admin_dashboard_path
  assert_nil page.response_headers['Permissions-Policy']
end
