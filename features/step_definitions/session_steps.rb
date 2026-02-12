# frozen_string_literal: true

Given "{provider} logs in" do |provider|
  set_current_domain(provider.external_admin_domain)
  username = provider.admins.first.username
  try_provider_login(username, 'superSecret1234#')
  assert user_is_logged_in(username)
end

# TODO: consider merging with steps with 'try to log in as provider'
# and/or with '{provider} logs in'
Given "{provider} tries to log in" do |provider|
  set_current_domain(provider.external_admin_domain)
  username = provider.admins.first.username
  try_provider_login(username, 'superSecret1234#')
end

Given /^I am logged in as (provider )?"([^\"]*)"$/ do |provider,username|
  if provider
    try_provider_login(username, 'superSecret1234#')
  else
    try_buyer_login_internal(username, 'superSecret1234#')
  end
  assert user_is_logged_in(username)
end

Given /^I am logged in as provider "([^\"]*)" on its admin domain$/ do |username|
  set_current_domain(Account.providers.find_by(org_name: username).external_admin_domain)
  try_provider_login(username, 'superSecret1234#')
  assert user_is_logged_in(username)
end

Given /^I am logged in as (provider )?"([^\"]*)" on (\S+)$/ do |provider,username, domain|
  # for some reason sometimes the domain is an array
  # In 1.9 Array#to_s is different so we need to handle it
  domain = domain.first if domain.is_a? Array

  set_current_domain(domain)

  if provider
    try_provider_login(username, 'superSecret1234#')
  else
    try_buyer_login_internal(username, 'superSecret1234#')
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
  username = master.admins.first.username
  try_provider_login(username, 'superSecret1234#')
  assert user_is_logged_in(username)
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
  assert user_is_logged_in(username)
end

When /^I log in as (provider )?"([^"]*)"$/ do |provider,username|
  if provider
    try_provider_login(username, 'superSecret1234#')
  else
    try_buyer_login_internal(username, 'superSecret1234#')
  end
  assert user_is_logged_in(username)
end

When "{buyer} logs in" do |buyer|
  set_current_domain(buyer.provider_account.domain)
  user = buyer.users.first
  try_buyer_login_internal(user.username, user.password || 'superSecret1234#')
  assert user_is_logged_in(user.username)
end

When /^I log in as (provider )?"([^"]*)" on (\S+)$/ do |provider,username, domain|
  # sometimes the domain is an array. In 1.9 Array#to_s is different
  # so we need to handle it
  domain = domain.first if domain.is_a? Array

  set_current_domain(domain)
  if provider
    try_provider_login(username, 'superSecret1234#')
  else
    try_buyer_login_internal(username, 'superSecret1234#')
  end
  assert user_is_logged_in(username)
end

When "I log in as {string} on the admin domain of {provider}" do |username, provider|
  set_current_domain(provider.internal_admin_domain)
  try_provider_login(username, 'superSecret1234#')
  assert user_is_logged_in(username)
end

When "(I )(they )try to log in as (buyer ){string}" do |username|
  try_buyer_login_internal(username, 'superSecret1234#')
end

When "I try to log in as {string} with password {string}" do |username, password|
  try_buyer_login_internal(username, password)
end

When "(I )(they )try to log in as provider {string}" do |username|
  try_provider_login(username, 'superSecret1234#')
end

When "I try to log in as provider {string} with password {string}" do |username, password|
  try_provider_login(username, password)
end

When /^I fill in the "([^"]*)" login data$/ do |username|
  fill_in('Username or Email', :with => username)
  fill_in('Password', :with => "superSecret1234#")
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
When /^(?:I am not|user is not) logged in$/ do
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

Then "(I )(they )should not be logged in" do
  assert_current_path %r{\A(/p/sessions|/session)\z}, ignore_query: true
end

When "{user} logs in" do |user|
  log_out
  try_provider_login(user.username, 'superSecret1234#')
  assert user_is_logged_in(user.username)
end
