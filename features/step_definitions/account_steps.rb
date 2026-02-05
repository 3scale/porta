# frozen_string_literal: true

Given "{provider} requires accounts to be approved" do |provider|
  provider.account_plans.each do |plan|
    plan.approval_required = true
    plan.save!
  end
end

Given "{account} has telephone number {string}" do |account, telephone_number|
  account.update_attribute(:telephone_number, telephone_number)
end

Given "admin of {account} has email {string}" do |account, email|
  account.admins.first.update_attribute(:email, email)
end

Given "{account} is deleted" do |account|
  account.delete
end

Then "{account} should be {state}" do |account, state|
  assert_equal state, account.state
end

Then /^I should see the account details:$/ do |table|
  assert_equal table.to_hash.flatten,
               find_all('#account-overview .pf-c-data-list__cell').map(&:text)
end

Then "{provider} time zone should be {string}" do |provider, time_zone|
  provider.timezone.should == time_zone
end

Then /^the provider time zone is "([^"]*)"$/ do |time_zone|
  @provider.update_column(:timezone, time_zone)
end

Then "new accounts with {plan} will be pending for approval" do |plan|
  params = Signup::SignupParams.new(plans: [plan], user_attributes: {
    password: 'superSecret1234#',
    username: 'pepe',
    email: 'pepe@example.com'
  }, account_attributes: {
    org_name: 'Banana API'
  }, defaults: {})
  signup = Signup::DeveloperAccountManager.new(current_account).create(params)
  assert signup.account_approval_required?
end

Then "{account} should be {account_type}" do |account, type|
  assert account.send("#{type}?"), "Account '#{account.org_name}' is not a #{type}"
end

Given "{buyer} has only one admin {string}" do |account, username|
  to_be_admin = account.users.find_by_username!(username)

  account.users.each do |user|
    user.update_attribute(:role, :member) unless user == to_be_admin
  end

  to_be_admin.update_attribute(:role, :admin)
end

Given "{provider} was created on {date}" do |provider, date|
  provider.update_attribute(:created_at, date.to_datetime)
end

When "the account will return an error when approved" do
  Account.any_instance.stubs(:approve).returns(false).once
end

When "the account will return an error when changing its plan" do
  Contract.any_instance.stubs(:change_plan).returns(false).once
end

When "the admin user is John Doe" do
  Account.any_instance.expects(:john_doe_still_here?).returns(true)
end
