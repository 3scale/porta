# frozen_string_literal: true

Given "{provider} logs in" do |provider|
  try_provider_login(provider.admins.first.username, 'supersecret')
end

Given /^I am logged in as (provider )?"([^\"]*)"$/ do |provider,username|
  if provider
    try_provider_login(username, 'supersecret')
  else
    try_buyer_login_internal(username, 'supersecret')
  end
end

Given /^I am logged in as provider "([^\"]*)" on its admin domain$/ do |username|
  set_current_domain(Account.providers.find_by(org_name: username).external_admin_domain)
  try_provider_login(username, 'supersecret')
end

Given /^I am logged in as (provider )?"([^\"]*)" on (\S+)$/ do |provider,username, domain|
  # for some reason sometimes the domain is an array
  # In 1.9 Array#to_s is different so we need to handle it
  domain = domain.first if domain.is_a? Array

  set_current_domain(domain)

  if provider
    try_provider_login(username, 'supersecret')
  else
    try_buyer_login_internal(username, 'supersecret')
  end
end

Given /^the master account admin has username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  user = Account.master.admins.first
  user.username = username
  user.password = password
  user.save!
end

When /^I am logged in as master admin on master domain$/ do
  master = Account.master
  set_current_domain(master.external_domain)
  try_provider_login(master.admins.first.username, 'supersecret')
end

# TODO: name this step better
# picks the right email inbox
When /^(?:they |I )?act as "([^"]*)"$/ do |username|
  act_as_user(username)
end

When /^I log in as (provider )?"([^"]*)" with password "([^"]*)"$/ do |provider,username, password|
  if provider
    try_provider_login(username, password)
  else
    try_buyer_login_internal(username, password)
  end
  assert_current_user(username)
end

When /^I log in as (provider )?"([^"]*)"$/ do |provider,username|
  if provider
    try_provider_login(username, 'supersecret')
  else
    try_buyer_login_internal(username, 'supersecret')
  end
end

When "{buyer} logs in" do |buyer|
  set_current_domain(buyer.provider_account.domain)
  user = buyer.users.first
  try_buyer_login_internal(user.username, user.password || 'supersecret')
end

When /^I log in as (provider )?"([^"]*)" on (\S+)$/ do |provider,username, domain|
  # sometimes the domain is an array. In 1.9 Array#to_s is different
  # so we need to handle it
  domain = domain.first if domain.is_a? Array

  set_current_domain(domain)
  if provider
    try_provider_login(username, 'supersecret')
  else
    try_buyer_login_internal(username, 'supersecret')
  end
end

When "I log in as {string} on the admin domain of {provider}" do |username, provider|
  set_current_domain(provider.internal_admin_domain)
  try_provider_login(username, 'supersecret')
end

When "I try to log in as {string}" do |username|
  try_buyer_login_internal(username, 'supersecret')
end

When "I try to log in as {string} with password {string}" do |username, password|
  try_buyer_login_internal(username, password)
end

When "I try to log in as provider {string}" do |username|
  try_provider_login(username, 'supersecret')
end

When "I try to log in as provider {string} with password {string}" do |username, password|
  try_provider_login(username, password)
end

When /^I fill in the "([^"]*)" login data$/ do |username|
  fill_in('Username or Email', :with => username)
  fill_in('Password', :with => "supersecret")
  click_button('Sign in')
end

Then /^(?:|I |they )should be logged in as "([^"]*)"$/ do |username|
  assert_current_user(username)
end

Then /^I should be logged in the Development Portal$/ do
  assert_current_user('foo')
  assert_current_path('/')
end

When /^(?:I|they) log ?out$/ do
  log_out
  @current_user = nil
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
  assert_includes [provider_sessions_path, session_path], current_path
end

When "the user logs in" do
  log_out
  try_provider_login(@user.username, 'supersecret')
end
