# frozen_string_literal: true

When /^the current domain is "?([^"\s]+)"?$/ do |domain|
  @provider = Account.same_domain(domain).take
  @domain = domain

  Capybara.current_session.reset!

  Capybara.app_host = Capybara.default_host = "http://#{domain}"
  Capybara.always_include_port = true
end

# Example:
#
#   When I hit "/potato" on domain "foo.3scale.localhost"
#
When /^I hit "([^"]*)" on ([^\s]+)$/ do |path,domain|
  step "the current domain is #{domain}"
  visit path
end

Given "current domain is the {word} domain of {provider}" do |level, provider|
  raise "Missing admin domain of #{provider.name}" if provider.internal_admin_domain.blank?
  step %(the current domain is #{level == 'admin' ? provider.external_admin_domain : 'the master domain'})
  @provider = provider
end

Then /^the current domain should be ([^\s]+)$/ do |domain|
  uri = URI.parse(current_url)
  assert_equal domain, uri.host
end

Then /^the current domain in a new window should be ([^\s]+)$/ do |domain|
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  step "the current domain should be #{domain}"
end

Then /^the current domain should be the master domain$/ do
  step %(the current domain should be "#{Account.master.external_domain}")
end

Then /^the current domain is the master domain$/ do
  step %(the current domain is "#{Account.master.external_domain}")
end

Then "the current domain should be the admin domain of {provider}" do |provider|
  step %(the current domain should be #{provider.external_admin_domain})
end


Then /^the current port should be (\d+)$/ do |port|
  uri = URI.parse(current_url)
  assert_equal port.to_i, uri.port
end

Then /^the current port should not be (\d+)$/ do |port|
  uri = URI.parse(current_url)
  assert_not_equal port.to_i, uri.port
end

Given "the admin domain of {provider} is {string}" do |provider, domain|
  provider.update_attribute :self_domain, domain
end

Given "the domain of {provider} is {string}" do |provider, domain|
  provider.update_attribute :domain, domain
end

Then "the domain of {provider} should be {string}" do |provider, domain|
  assert provider.match_internal_domain?(domain)
end

Then "the admin domain of {provider} should be {string}" do |provider, domain|
  assert provider.match_internal_admin_domain?(domain)
end
