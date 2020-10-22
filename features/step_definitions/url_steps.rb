# frozen_string_literal: true

When "the current domain is {string}" do |domain|
  @provider = Account.same_domain(domain).take
  @domain = domain

  Capybara.current_session.reset!

  Capybara.app_host = Capybara.default_host = "http://#{domain}"
  Capybara.always_include_port = true
end

When "I hit {string} on {string}" do |path, domain|
  step %(the current domain is "#{domain}")
  visit path
end

Given "current domain is the {word} domain of {provider}" do |level, provider|
  raise "Missing admin domain of #{provider.name}" if provider.admin_domain.blank?

  step %(the current domain is "#{level == 'admin' ? provider.admin_domain : 'the master domain'}")
  @provider = provider
end

Then "the current domain should be {word}" do |domain|
  uri = URI.parse(current_url)
  assert_equal domain, uri.host
end

Then "the current domain in a new window should be {word}" do |domain|
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  step "the current domain should be #{domain}"
end

Then "the current domain should be the master domain" do
  step %(the current domain should be "#{Account.master.domain}")
end

Then "the current domain is the master domain" do
  step %(the current domain is "#{Account.master.domain}")
end

Then "the current domain should be the admin domain of {provider}" do |provider|
  step %(the current domain should be #{provider.admin_domain})
end

Then "the current port should be {int}" do |port|
  uri = URI.parse(current_url)
  assert_equal port, uri.port
end

Then "the current port should not be {int}" do |port|
  uri = URI.parse(current_url)
  assert_not_equal port.to_i, uri.port
end

Given "the admin domain of {provider} is {string}" do |provider, domain|
  provider.update!(self_domain: domain)
end

Given "the domain of {provider} is {string}" do |provider, domain|
  provider.update!(domain: domain)
end

Then "the domain of {provider} should be {string}" do |provider, domain|
  assert_equal domain, provider.domain
end

Then "the admin domain of {provider} should be {string}" do |provider, domain|
  assert_equal domain, provider.admin_domain
end
