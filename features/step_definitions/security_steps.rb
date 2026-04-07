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

Then('the admin portal should have Permissions-Policy header {string}') do |expected_value|
  setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
  assert_not_nil setting, "Expected admin portal Permissions-Policy setting to exist"
  assert_equal expected_value, setting.value
end

Then('the admin portal should not have Permissions-Policy header') do
  setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
  assert setting.nil? || setting.value.blank?, "Expected admin portal Permissions-Policy to be blank or not exist"
end

Then('the developer portal should have Permissions-Policy header {string}') do |expected_value|
  setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderDeveloper')
  assert_not_nil setting, "Expected developer portal Permissions-Policy setting to exist"
  assert_equal expected_value, setting.value
end

Then('the developer portal should not have Permissions-Policy header') do
  setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderDeveloper')
  assert setting.nil? || setting.value.blank?, "Expected developer portal Permissions-Policy to be blank or not exist"
end
