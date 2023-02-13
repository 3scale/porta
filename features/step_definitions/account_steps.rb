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
  table.diff! extract_table('#account-overview', 'tr', 'th,td')
end

Then "{provider} time zone should be {string}" do |provider, time_zone|
  provider.timezone.should == time_zone
end

Then /^the provider time zone is "([^"]*)"$/ do |time_zone|
  @provider.update_column(:timezone, time_zone)
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
