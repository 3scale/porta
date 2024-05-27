# frozen_string_literal: true

Given "an admin user {string} of {provider}" do |username, provider|
  @user = FactoryBot.create(:active_user, account: provider,
                                          username: username,
                                          role: :admin)
end

Given "a member user {string} of {provider}" do |username, provider|
  @user = FactoryBot.create(:active_user, account: provider,
                                          username: username,
                                          role: :member)
end

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

Given "an (active )admin {string} of the provider" do |username|
  FactoryBot.create(:active_admin, account: @provider, username: username)
end

Given "an active user {string} of {account} with {word} permission" do |username, account, permission|
  user = FactoryBot.create(:active_user, account: account, username: username)

  user.admin_sections = permission == 'no' ? [] : [permission]

  user.save!(validate: false)
end

Given "an active user {string} of {account} with email {string}" do |username, account, email|
  @user = FactoryBot.create(:active_user, account: account, username: username, email: email)
end

Given "{user} is suspended" do |user|
  user.suspend! unless user.suspended?
end

Given "{user} is email unverified" do |user|
  user.email_unverify! unless user.email_unverified?
end

Given "{user} was signed up with password" do |user|
  user.update(signup_type: nil)
end

Given "{user} has email {string}" do |user, email|
  user.update!(:email => email)
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

Given "the current user {can} export data" do |can|
  Ability.any_instance.stubs(:can?).with(:manage, any_parameters).returns(true)
  Ability.any_instance.stubs(:can?).with(:admin, any_parameters).returns(true)
  Ability.any_instance.stubs(:can?).with(:see, any_parameters).returns(true)
  Ability.any_instance.stubs(:can?).with(:impersonate, any_parameters).returns(true)
  Ability.any_instance.stubs(:can?).with(:update, any_parameters).returns(true)
  Ability.any_instance.stubs(:can?).with(:show, any_parameters).returns(true)
  Ability.any_instance.stubs(:can?).with(:read, any_parameters).returns(true)
  Ability.any_instance.stubs(:can?).with(:create, any_parameters).returns(true)

  Ability.any_instance.expects(:can?).with(:export, :data).returns(can).at_least_once
end
