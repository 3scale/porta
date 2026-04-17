# frozen_string_literal: true

Given('the provider has configured {word} portal Permissions-Policy {string}') do |portal, policy_value|
  @provider.account_settings.create!(
    type: "AccountSetting::PermissionsPolicyHeader#{portal.capitalize}",
    value: policy_value
  )
end

Then('the {word} portal should have configured Permissions-Policy header {string}') do |portal, expected_value|
  setting = @provider.account_settings.find_by(type: "AccountSetting::PermissionsPolicyHeader#{portal.capitalize}")
  assert_not_nil setting, "Expected #{portal} portal Permissions-Policy setting to exist"
  assert_equal expected_value, setting.value
end

Then('the {word} portal should not have configured Permissions-Policy header') do |portal|
  setting = @provider.account_settings.find_by(type: "AccountSetting::PermissionsPolicyHeader#{portal.capitalize}")
  assert setting.nil? || setting.value.blank?, "Expected #{portal} portal Permissions-Policy to be blank or not exist"
end
