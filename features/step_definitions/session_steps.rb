# frozen_string_literal: true

Given /^I am logged in as (provider )?"([^\"]*)"$/ do |provider,username|
  if provider
    step %{I log in as provider "#{username}"}
  else
    step %{I log in as "#{username}"}
  end
end

Given /^I am logged in as provider "([^\"]*)" on its admin domain$/ do |username|
  step %{current domain is the admin domain of provider "#{username}"}
  step %{I am logged in as provider "#{username}"}
end

Given /^I am logged in as (provider )?"([^\"]*)" on (\S+)$/ do |provider,username, domain|
  # for some reason sometimes the domain is an array
  # In 1.9 Array#to_s is different so we need to handle it
  domain = domain.first if domain.is_a? Array

  step %(the current domain is #{domain})

  if provider
    step %(I log in as provider "#{username}")
  else
    step %(I log in as "#{username}")
  end
end

Given /^the master account admin has username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  user = Account.master.admins.first
  user.username = username
  user.password = password
  user.save!
end

When /^I am logged in as master admin on master domain$/ do
  step %(the current domain is #{Account.master.domain})
  step %(I log in as provider "#{Account.master.admins.first.username}")
end

# TODO: name this step better
# picks the right email inbox
When /^I act as "([^"]*)"$/ do |username|
  act_as_user(username)
end

When /^I log in as (provider )?"([^"]*)" with password "([^"]*)"$/ do |provider,username, password|
  if provider
    step %(I try to log in as provider "#{username}" with password "#{password}")
  else
    step %(I try to log in as "#{username}" with password "#{password}")
  end
  step %(I should be logged in as "#{username}")
end

When /^I log in as (provider )?"([^"]*)"$/ do |provider,username|
  if provider
    step %(I log in as provider "#{username}" with password "supersecret")
  else
    step %(I log in as "#{username}" with password "supersecret")
  end
end

When /^I log in as (provider )?"([^"]*)" on (\S+)$/ do |provider,username, domain|
  # sometimes the domain is an array. In 1.9 Array#to_s is different
  # so we need to handle it
  domain = domain.first if domain.is_a? Array

  if provider
    step %{I am logged in as provider "#{username}" on #{domain}}
  else
    step %{I am logged in as "#{username}" on #{domain}}
  end
end

When "I log in as {string} on the admin domain of {provider}" do |username, provider|
  step %(I log in as provider "#{username}" on #{provider.admin_domain})
end


When /^I try to log in as (provider )?"([^"]*)"$/ do |provider,username|
  if provider
    step %(I try to log in as provider "#{username}" with password "supersecret")
  else
    step %(I try to log in as "#{username}" with password "supersecret")
  end
end

When /^I try to log in as (provider )?"([^"]*)" with password "([^"]*)"$/ do |provider,username, password|
  # TODO: simplify and DRY
  path = if provider
           provider_login_path
         else
           login_path
         end

  visit path

  if provider
    fill_in('Email or Username', :with => username)
  else
    fill_in('Username or Email', :with => username)
  end
  fill_in('Password', :with => password)
  click_button('Sign in')
end

When /^I fill in the "([^"]*)" login data$/ do |username|
  fill_in('Username or Email', :with => username)
  fill_in('Password', :with => "supersecret")
  click_button('Sign in')
end

Then /^I should be logged in as "([^"]*)"$/ do |username|
  message = "Expected #{username} to be logged in, but is not"
  assert has_content?(/Signed (?:in|up) successfully/i), message
end

Then /^I should be logged in the Developer Portal$/ do
  steps <<-GHERKIN
    Then I should be logged in as "foo"
    And I should be at url for the home page
  GHERKIN
end

When /^I log ?out$/ do
  visit '#session-menu'
  click_link 'Sign Out' || 'Log Out'
end

# TODO: merge those 3 assertion steps
When /^I am not logged in$/ do
  if Account.exists?(domain: @domain)
    visit '/admin'
  else
    visit '/p/admin/dashboard'
  end

  assert has_no_css?('#user_widget .username')

  page.reset_session!
end

Then /^I should not be logged in as "([^"]*)"$/ do |username|
  assert has_no_css?('#user_widget .username', :text => username)
end

Then /^I should not be logged in$/ do
  # HAX: Check the logout link is not present. Don't know how to check this in a more explicit way.
  step 'I should not see link to logout'
end
