# frozen_string_literal: true

Given "I am logged in as provider {string}" do |username|
  step %(I log in as provider "#{username}")
end

Given "I am logged in as {string}" do |username|
  step %(I log in as "#{username}")
end

Given "I am logged in as provider {string} on its admin domain" do |username|
  step %(current domain is the admin domain of provider "#{username}")
  step %(I am logged in as provider "#{username}")
end

Given "I am logged in as {string} on {}" do |username, domain|
  # for some reason sometimes the domain is an array
  # In 1.9 Array#to_s is different so we need to handle it
  domain = domain.first if domain.is_a? Array

  step %(the current domain is #{domain})
  step %(I log in as "#{username}")
end

Given "I am logged in as provider {string} on {}" do |username, domain|
  # for some reason sometimes the domain is an array
  # In 1.9 Array#to_s is different so we need to handle it
  domain = domain.first if domain.is_a? Array

  step %(the current domain is #{domain})
  step %(I log in as provider "#{username}")
end

Given "the master account admin has username {string} and password {string}" do |username, password|
  user = Account.master.admins.first
  user.username = username
  user.password = password
  user.save!
end

When "I am logged in as master admin on master domain" do
  step %(the current domain is #{Account.master.domain})
  step %(I log in as provider "#{Account.master.admins.first.username}")
end

# TODO: name this step better
# picks the right email inbox
When "I act as {string}" do |username|
  act_as_user(username)
end

When "I log in as {string} with password {string}" do |username, password|
  step %(I try to log in as "#{username}" with password "#{password}")
  step %(I should be logged in as "#{username}")
end

When "I log in as provider {string} with password {string}" do |username, password|
  step %(I try to log in as provider "#{username}" with password "#{password}")
  step %(I should be logged in as "#{username}")
end

When "I log in as {string}" do |username|
  step %(I log in as "#{username}" with password "supersecret")
end

When "I log in as provider {string}" do |username|
  step %(I log in as provider "#{username}" with password "supersecret")
end

When "I log in as {string} on {}" do |username, domain|
  # sometimes the domain is an array. In 1.9 Array#to_s is different
  # so we need to handle it
  domain = domain.first if domain.is_a? Array
  step %(I am logged in as "#{username}" on #{domain})
end

When "I log in as provider {string} on {}" do |username, domain|
  # sometimes the domain is an array. In 1.9 Array#to_s is different
  # so we need to handle it
  domain = domain.first if domain.is_a? Array
  step %(I am logged in as provider "#{username}" on #{domain})
end

When "I log in as {string} on the admin domain of {provider}" do |username, provider|
  step %(I log in as provider "#{username}" on #{provider.admin_domain})
end

When "I try to log in as {string}" do |username|
  step %(I try to log in as "#{username}" with password "supersecret")
end

When "I try to log in as provider {string}" do |username|
  step %(I try to log in as provider "#{username}" with password "supersecret")
end

When "I try to log in as {string} with password {string}" do |username, password|
  visit login_path
  fill_in_login_data(username, password)
  click_button('Sign in')
end

When "I try to log in as provider {string} with password {string}" do |username, password|
  # binding.pry
  visit provider_login_path
  fill_in_login_data(username, password)
end

When "I fill in the {string} login data" do |username|
  fill_in_login_data(username)
end

def fill_in_login_data(username, password = 'supersecret')
  fill_in('Username or Email', with: username)
  fill_in('Password', with: password)
  click_button('Sign in')
end

Then "I {should} be logged in as {string}" do |logged_in, username|
  if logged_in
    message = "Expected #{username} to be logged in, but is not"
    assert has_content?(/Signed (?:in|up) successfully/i), message
  else
    assert has_no_css?('#user_widget .username', text: username)
  end
end

Then "I should be logged in the Development Portal" do
  steps %(
    Then I should be logged in as "foo"
    And I should be at url for the home page
  )
end

When "I log( )out" do
  visit '#session-menu'
  click_link 'Sign Out' || 'Log Out'
end

# TODO: merge those 3 assertion steps
When "I am not logged in" do
  if Account.exists?(domain: @domain)
    visit '/admin'
  else
    visit '/p/admin/dashboard'
  end

  assert has_no_css?('#user_widget .username')

  page.reset_session!
end

Then "I should not be logged in" do
  # HAX: Check the logout link is not present. Don't know how to check this in a more explicit way.
  step 'I should not see link to logout'
end
