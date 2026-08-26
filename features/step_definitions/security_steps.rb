# frozen_string_literal: true

def header_setting_type(header_name, portal)
  class_prefix = header_name.split(/[\s-]/).map(&:capitalize).join
  "#{class_prefix}Header#{portal.capitalize}"
end

Given(/^the provider has configured (\w+) portal (.+?) "([^"]*)"$/) do |portal, header_name, value|
  @provider.account_settings.create!(
    type: header_setting_type(header_name, portal),
    value: value
  )
end

Then(/^the (\w+) portal should have configured (.+?) header "([^"]*)"$/) do |portal, header_name, expected_value|
  setting = @provider.account_settings.find_by(type: header_setting_type(header_name, portal))
  assert_not_nil setting, "Expected #{portal} portal #{header_name} setting to exist"
  assert_equal expected_value, setting.value
end

Then(/^the (\w+) portal should not have configured (.+?) header$/) do |portal, header_name|
  setting = @provider.account_settings.find_by(type: header_setting_type(header_name, portal))
  assert setting.nil? || setting.value.blank?, "Expected #{portal} portal #{header_name} to be blank or not exist"
end
