When /^the current domain is "?([^"\s]+)"?$/ do |domain|
  @provider = Account.same_domain(domain).take
  @domain = domain

  Capybara.current_session.reset!

  Capybara.app_host = Capybara.default_host = "http://#{domain}"
  Capybara.always_include_port = true
end

# Example:
#
#   When I hit "/potato" on domain "foo.example.com"
#
When /^I hit "([^"]*)" on ([^\s]+)$/ do |path,domain|
  step "the current domain is #{domain}"
  visit path
end

When /^current domain is the admin domain of (provider "[^"]*")$/ do |provider|
  raise "Missing admin domain of #{provider.name}" if provider.admin_domain.blank?
  step %(the current domain is #{provider.admin_domain})
  @provider = provider
end

Then /^the current domain should(?: still)? be ([^\s]+)$/ do |domain|
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  uri = URI.parse(current_url)
  assert_equal domain, uri.host
end

Then /^the current domain should be the master domain$/ do
  step %(the current domain should be "#{Account.master.domain}")
end

Then /^the current domain is the master domain$/ do
  step %(the current domain is "#{Account.master.domain}")
end

Then /^the current domain should be the admin domain of (provider "[^"]*")$/ do |provider|
  step %(the current domain should be #{provider.admin_domain})
end


Then /^the current port should be (\d+)$/ do |port|
  uri = URI.parse(current_url)
  assert_equal port.to_i, uri.port
end

Then /^the current port should not be (\d+)$/ do |port|
  uri = URI.parse(current_url)
  assert_not_equal port.to_i, uri.port
end

Given /^the admin domain of (provider "[^"]*") is "([^"]*)"$/ do |provider, domain|
  provider.update_attribute :self_domain, domain
end

Given /^the domain of (provider "[^"]*") is "([^"]*)"$/ do |provider, domain|
  provider.update_attribute :domain, domain
end

Then /^the domain of (provider "[^"]*") should be "([^"]*)"$/ do |provider, domain|
  assert_equal domain, provider.domain
end

Then /^the admin domain of (provider "[^"]*") should be "([^"]*)"$/ do |provider, domain|
  assert_equal domain, provider.admin_domain
end
