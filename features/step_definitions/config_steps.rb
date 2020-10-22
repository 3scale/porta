# frozen_string_literal: true

Given "{provider} has config value {string} set to true/false" do |provider, name|
  raise 'Use specific settings step!'
end

Given "{provider} has signup {enabled}" do |provider, enabled|
  if enabled
    provider.enable_signup!
  else
    provider.disable_signup!
  end
end

Given "{provider} has multiple applications {enabled}" do |provider, enabled|
  if enabled
    provider.settings.allow_multiple_applications!
    provider.settings.show_multiple_applications!
  elsif provider.settings.can_deny_multiple_applications?
    provider.settings.deny_multiple_applications!
  end
end

Given "the provider has multiple applications {enabled}" do |enabled|
  step %(provider "#{provider_or_master_name}" has multiple applications #{enabled})
end

Given "{provider} has Browser CMS {activated}" do |provider, activated|
  raise 'BCMS cannot be deactivated!' unless activated
end

Given "{provider} uses backend {backend_version} in his default service" do |provider, backend_version|
  service = provider.default_service
  service.backend_version = backend_version
  service.save!
end

When "I press {string} for config value {string}" do |label, name|
  widget = find(%(table#configs th:contains("#{name}") ~ td button:contains("#{label}")))
  widget.click
end

When "I fill in config value {string} with {string}" do |name, value|
  field = find(%(table#configs th:contains("#{name}") ~ td input[type=text][name=value]))
  field.set(value)
end

When "I {check} config value {string}" do |action, name|
  field = find(%(table#configs th:contains("#{name}") ~ td input[type=checkbox][name=value]))
  field.set(action == 'check')
  field.select_option #this is needed due some issues of capybara-webkit with checkboxes, should be ok for other drivers
end

When "I select {string} for config value {string}" do |value, name|
  field = find(%(table#configs th:contains("#{name}") ~ td select))
  field.find(%(option:contains("#{value}"))).select_option
end

Then "{provider} should have config value {string} set to {string}" do |provider, name, value|
  assert_equal value, provider.config[name]
end

Then "{provider} should have config value {string} {set}" do |provider, name, set|
  assert_equal set, provider.config[name]
end

Then "{provider} should not have config value {string}" do |provider, name|
  assert_nil provider.config[name]
end

Then "I should see config value {string} set to {string}" do |name, value|
  assert has_css?(%(table#configs th:contains("#{name}") ~ td input[type=text][name=value][value = "#{value}"]))
end

Then "I should see config value {string} {set}" do |name, set|
  input = find(%(table#configs th:contains("#{name}") ~ td input[type=checkbox][name=value]))
  assert_not_nil input

  assert_equal set, input[:checked]
end

Then "I should see config value {string} has {string} selected" do |name, value|
  option = find(%(table#configs th:contains("#{name}") ~ td option[selected]))

  assert_equal value.to_s, option.text
end

Then "I should see config value {string} has the blank option selected" do |name|
  option = find(%(table#configs th:contains("#{name}") ~ td select option[selected]))
  assert option[:value].blank?
end

Then "I should not see config value {string}" do |name|
  assert has_no_css?(%(table#configs th:contains("#{name}")))
end

Then "I should see button {string} for config value {string}" do |label, name|
  assert has_css?(%(table#configs th:contains("#{name}") ~ td button:contains("#{label}")))
end

Then "I should not see button {string} for config value {string}" do |label, name|
  assert has_no_css?(%(table#configs th:contains("#{name}") ~ td button:contains("#{label}")))
end

Given "{provider} uses {authentication_strategy} authentication" do |provider, strategy|
  settings = provider.settings
  settings.authentication_strategy = strategy.downcase
  settings.cas_server_url = "http://mamacit.as" if strategy.casecmp("cas").zero?

  settings.save!
end
