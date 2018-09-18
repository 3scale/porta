When /^I request the settings page$/ do
  visit admin_site_settings_path
end

# TODO: remove

# TODO: remove
When /^I request the url "([^"]*)"$/ do |url|
  visit url
end
