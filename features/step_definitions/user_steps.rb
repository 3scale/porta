# frozen_string_literal: true

Given "a(n) {user_type} {string} of {account}" do |user_type, username, account|
  FactoryBot.create(user_type, account: account, username: username)
end

Given "a(n) {user_type} of {account} with first name {string} and last name {string}" do |user_type, account, first_name, last_name|
  FactoryBot.create(user_type, account: account, first_name: first_name, last_name: last_name)
end

Given "a(n) {user_type} {string} of {account} with email {string}" do |user_type, username, account, email|
  FactoryBot.create(user_type, account: account, username: username, email: email)
end

Given "a(n) {user_type} {string} of {account} with {string} permission" do |user_type, username, account, permission|
  user = FactoryBot.create(user_type, account: account, username: username)

  user.admin_sections = permission == 'no' ? [] : [permission]

  user.save!(validate: false)
end

Given "there is no user with username {string}" do |username|
  assert_nil User.find_by(username: username)
end

Given "{user} is suspended" do |user|
  user.suspend! unless user.suspended?
end

Given "{user} is active" do |user|
  user.activate! unless user.active?
end

Given "{user} is email unverified" do |user|
  user.email_unverify! unless user.email_unverified?
end

Given "provider {string} has the following users:" do |provider_name, table|
  table.hashes.each do |hash|
    step %(an #{hash['State'] || 'active'} user "#{hash['User']}" of account "#{provider_name}")
  end
end

Given "{user} has first name {string} and last name {string}" do |user, first_name, last_name|
  user.update!(first_name: first_name, last_name: last_name)
end

Given "{user} has email {string}" do |user, email|
  user.update!(email: email)
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

Given "{provider} has user {string}" do |provider, username|
  user = provider.users.first
  user.update!(username: username)
end

When "I navigate to my personal details page" do
  click_link 'Account'
  click_link 'Personal'
  click_link 'Personal Details'
end

When "I fill in my email with {string}" do |email|
  fill_in "Email", with: email
end

When "I commit the changes to my personal details" do
  click_button 'Update details'
end

When "I change my email to {string}" do |new_email|
  step "I navigate to my personal details page"
  step %(I fill in my email with "#{new_email}")
  step "I commit the changes to my personal details"
end

When "I follow the link to verify email in the email to verify email address" do
  open_last_email
  first_link = current_email.body.scan(/http[^\s]+/).first
  visit(first_link)
end

When "I change my name without changing the email" do
  reset_mailer
  fill_in "user_first_name", with: "anyname"
end

When "I press the button to suspend the user" do
  click_button "Suspend"
end

When "I press the button to unsuspend the user" do
  click_button "Unsuspend"
end

Then "there should be no user with username {string}" do |username|
  assert_nil User.find_by(username: username)
end

Then "there should be an user with username {string}" do |username|
  assert_not_nil User.find_by!(username: username)
end

Then "there should be no user with username {string} of {account}" do |username, account|
  assert_nil account.users.find_by(username: username)
end

Then "{user} should have role {string}" do |user, role|
  assert_equal role.to_sym, user.role
end

Then "{user} should be {state}" do |user, state|
  assert user.send("#{state}?")
end

Then "{user} should have last login on {} from {}" do |user, time, ip|
  assert_equal Time.zone.parse(time).beginning_of_hour, user.last_login_at.beginning_of_hour
  assert_equal ip, user.last_login_ip
end

Then "I should see the notice to validate my email" do
  assert has_content?('Validate your email')
end

Then "I should see the notice that the email is verified" do
  response.body.should have_regexp /Email correctly verified/
end

Then "{user} should receive an email to verify email address" do |user|
  step %("#{user.email}" should receive an email to verify email address)
end

Then "I should not see the link to my account's users" do
  response.body.should_not have_tag 'a#account_users'
end

Then "show me signed up users" do
  puts "********* USER INFO **********"
  puts "number: #{User.count}"
  puts "details: #{User.last.to_yaml}"
end
