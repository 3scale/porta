Given /^(provider "[^\"]*") has "([^\"]*)" disabled$/ do |account, toggle|
  account.settings.update_attribute("#{underscore_spaces(toggle)}_enabled", false)
end

Given /^(provider "[^\"]*") has "([^\"]*)" enabled$/ do |account, toggle|
  account.settings.update_attribute("#{underscore_spaces(toggle)}_enabled", true)
end


Given /^(provider "[^\"]*") has "([^\"]*)" set to "([^\"]*)"$/ do |account, name, value|
  account.settings.update_attribute(underscore_spaces(name), value)
end

Given /^(provider "[^\"]*") has the following settings:$/ do |account, table|
  attributes = table.rows_hash
  attributes.map_keys! { |key| underscore_spaces(key) }

  account.settings.update_attributes!(attributes)
end

Given /^(buyer "[^\"]*") has "([^\"]*)" enabled$/ do |account, setting|
  account.settings.update_attribute("#{underscore_spaces(setting)}_enabled", true)
end

When /^I (check|uncheck) "([^"]*)" for the "([^"]*)" module$/ do |action, widget, name|
  send action, "settings_#{name.downcase}_#{widget.downcase}"
end

Then /^I should see the settings updated$/ do
  assert has_content?("Settings updated.")
end

Then /^(provider "[^"]*") should have strong passwords enabled$/ do |provider|
  assert provider.settings.strong_passwords_enabled
end

Then /^(provider "[^"]*") should have strong passwords disabled$/ do |provider|
  assert false == provider.settings.strong_passwords_enabled
end

When /^I select backend version "([^"]*)"$/ do |version|
  find(:xpath, "//input[@id='service_backend_version_#{version}']").select_option
end
