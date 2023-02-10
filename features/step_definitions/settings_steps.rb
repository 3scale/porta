# frozen_string_literal: true

Given "{provider} has {string} {enabled}" do |account, toggle, enabled|
  account.settings.update_attribute("#{underscore_spaces(toggle)}_enabled", enabled)
end

Given "{provider} has {string} set to {string}" do |account, name, value|
  account.settings.update_attribute(underscore_spaces(name), value)
end

Given "{provider} has the following settings:" do |account, table|
  attributes = table.rows_hash
  attributes.map_keys! { |key| underscore_spaces(key) }

  account.settings.update_attributes!(attributes)
end

Then /^I should see the settings updated$/ do
  assert has_content?("Settings updated.")
end

Then "{provider} should have strong passwords {enabled}" do |provider, enabled|
  assert provider.settings.strong_passwords_enabled == enabled
end

Then(/^I should see field "([^"]*)" (enabled|disabled)$/) do |field, enabled|
  label = find('label', text: field)
  input = label.sibling('input')

  assert_not_equal enabled, input.disabled?
end
