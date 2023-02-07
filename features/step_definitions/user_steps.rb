# frozen_string_literal: true

Given "an user {string} of {account}" do |username, account|
  FactoryBot.create(:user, :account => account, :username => username)
end

Given "an user of {account} with first name {string} and last name {string}" do |account, first_name, last_name|
  FactoryBot.create(:user, :account => account, :first_name => first_name, :last_name => last_name)
end

Given "a pending user {string} of {account}" do |username, account|
  FactoryBot.create(:pending_user, :account => account, :username => username)
end

Given "an active user {string} of {account}" do |username, account|
  FactoryBot.create(:active_user, :account => account, :username => username)
end

Given "an active admin {string} of {account}" do |username, account|
  FactoryBot.create(:active_admin, :account => account, :username => username)
end

Given "an active user {string} of {account} with {word} permission" do |username, account, permission|
  user = FactoryBot.create(:active_user, account: account, username: username)

  user.admin_sections = permission == 'no' ? [] : [permission]

  user.save!(validate: false)
end

Given "an active user {string} of {account} with email {string}" do |username, account, email|
  FactoryBot.create(:active_user, :account => account, :username => username, :email => email)
end

Given "{user} is suspended" do |user|
  user.suspend! unless user.suspended?
end

Given "{user} is email unverified" do |user|
  user.email_unverify! unless user.email_unverified?
end

Given /^provider "([^\"]*)" has the following users:$/ do |provider_name, table|
  table.hashes.each do |hash|
    step %(an #{hash['State'] || 'active'} user "#{hash['User']}" of account "#{provider_name}")
  end
end

Given "{user} has email {string}" do |user, email|
  user.update_attributes!(:email => email)
end

Given "the admin of {account} has password {string}" do |account, password|
  user = account.admins.first
  user.password = password
  user.save!
end

Given "the admin of {account} has email {string}" do |account, email|
  user = account.admins.first
  user.email = email
  user.save!
end

Given "the {user} is activated" do |user|
  user.activate!
end

Given "{user} has role {string}" do |user, role|
  user.update!(role: role.to_sym)
end

When /^I press the button to suspend the user$/ do
  click_button "Suspend"
end

When /^I press the button to unsuspend the user$/ do
  click_button "Unsuspend"
end

Then "there should be no user with username {string} of {account}" do |username, account|
  assert_nil account.users.find_by_username(username)
end

Then "{user} should have role {string}" do |user, role|
  assert_equal role.to_sym, user.role
end

Then "{user} should be {state}" do |user, state|
  assert user.send("#{state}?")
end

Then /^I should see the notice to validate my email$/ do
  assert has_content?('Validate your email')
end
