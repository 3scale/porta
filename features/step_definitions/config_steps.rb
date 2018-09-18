
Given /^(provider "[^"]*") has config value "([^"]*)" set to (true|false)$/ do |provider, name, value|
  raise 'Use specific settings step!'
end

Given /^(provider "[^"]*") has signup (enabled|disabled)$/ do |provider, value|
  if value == 'enabled'
    provider.enable_signup!
  else
    provider.disable_signup!
  end
end

Given /^(provider "[^"]*") has multiple applications (enabled|disabled)$/ do |provider, value|
  if value == 'enabled'
    provider.settings.allow_multiple_applications!
    provider.settings.show_multiple_applications!
  elsif provider.settings.can_deny_multiple_applications?
    provider.settings.deny_multiple_applications!
  end
end

Given /^the provider has multiple applications (enabled|disabled)$/ do |value|
  step %(provider "#{provider_or_master_name}" has multiple applications #{value})
end

Given /^provider "([^"]*)" has Browser CMS (activated|deactivated)$/ do |provider, value|
  if value == 'deactivated'
    raise 'BCMS cannot be deactivated!'
  end
end


Given /^(provider "[^\"]*") uses backend (?:v(\d+)|(oauth)) in his default service$/ do |provider, version,oauth|
  service = provider.default_service
  service.backend_version = oauth || version
  service.save!
end


When /^I press "([^"]*)" for config value "([^"]*)"$/ do |label, name|
  widget = find(%(table#configs th:contains("#{name}") ~ td button:contains("#{label}")))
  widget.click
end

When /^I fill in config value "([^"]*)" with "([^"]*)"$/ do |name, value|
  field = find(%(table#configs th:contains("#{name}") ~ td input[type=text][name=value]))
  field.set(value)
end

When /^I (check|uncheck) config value "([^"]*)"$/ do |action, name|
  field = find(%(table#configs th:contains("#{name}") ~ td input[type=checkbox][name=value]))
  field.set(action == 'check')
  field.select_option #this is needed due some issues of capybara-webkit with checkboxes, should be ok for other drivers
end

When /^I select "([^"]*)" for config value "([^"]*)"$/ do |value, name|
  field = find(%(table#configs th:contains("#{name}") ~ td select))
  field.find(%(option:contains("#{value}"))).select_option
end

Then /^(provider "[^"]*") should have config value "([^"]*)" set to "([^"]*)"$/ do |provider, name, value|
  assert_equal value, provider.config[name]
end

Then /^(provider "[^"]*") should have config value "([^"]*)" set to (true|false)$/ do |provider, name, value|
  assert_equal (value == 'true'), provider.config[name]
end

Then /^(provider "[^"]*") should not have config value "([^"]*)"$/ do |provider, name|
  assert_nil provider.config[name]
end

Then /^I should see config value "([^"]*)" set to "([^"]*)"$/ do |name, value|
  assert has_css?(%(table#configs th:contains("#{name}") ~ td input[type=text][name=value][value = "#{value}"]))
end

Then /^I should see config value "([^"]*)" set to (true|false)$/ do |name, value|
  input = find(%(table#configs th:contains("#{name}") ~ td input[type=checkbox][name=value]))
  assert_not_nil input

  if value == 'true'
    assert  input[:checked]
  else
    assert !input[:checked]
  end
end

Then /^I should see config value "([^"]*)" has "([^"]*)" selected$/ do |name, value|
  option = find(%(table#configs th:contains("#{name}") ~ td option[selected]))

  assert_equal value.to_s, option.text
end

Then /^I should see config value "([^"]*)" has the blank option selected$/ do |name|
  option = find(%(table#configs th:contains("#{name}") ~ td select option[selected]))
  assert option[:value].blank?
end

Then /^I should not see config value "([^"]*)"$/ do |name|
  assert has_no_css?(%(table#configs th:contains("#{name}")))
end

Then /^I should see button "([^"]*)" for config value "([^"]*)"$/ do |label, name|
  assert has_css?(%(table#configs th:contains("#{name}") ~ td button:contains("#{label}")))
end

Then /^I should not see button "([^"]*)" for config value "([^"]*)"$/ do |label, name|
  assert has_no_css?(%(table#configs th:contains("#{name}") ~ td button:contains("#{label}")))
end


Given /^(provider "[^\"]*") uses (Janrain|internal|Cas) authentication$/ do |provider, strategy|
  settings = provider.settings
  settings.authentication_strategy = strategy.downcase
  settings.cas_server_url = "http://mamacit.as" if strategy.casecmp("cas").zero?

  settings.save!
end
