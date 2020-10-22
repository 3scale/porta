# frozen_string_literal: true

Given "{provider} requires accounts to be approved" do |provider|
  provider.account_plans.each do |plan|
    plan.approval_required = true
    plan.save!
  end
end

Given "{provider} has valid personal details" do |provider|
  provider.state_region = "foo"
  provider.city = "bar"
  provider.zip = "zop"
  provider.vat_code = "42"
  provider.save
end

Given "{account} has address {string}" do |account, address|
  account.update!(org_legaladdress: address)
end

Given "an account {string} signed up to {plan}" do |account_name, plan|
  account = FactoryBot.create(:account, provider_account: plan.provider_account, org_name: account_name)
  account.admin.activate!
  account.buy!(plan)
end

Given "{account} has telephone number {string}" do |account, telephone_number|
  account.update!(telephone_number: telephone_number)
end

Given "admin of {account} has email {string}" do |account, email|
  account.admins.first.update!(email: email)
end

Given "{account} is deleted" do |account|
  account.delete
end

When "I change the value of the customers type field to {string}" do |value|
  check value
end

When "I press the button to update account" do
  click_button "Update Account"
end

When "I navigate to the account {string} overview page" do |account|
  step %(I follow "Partners")
  step %(I follow "#{account}")
end

When "I cancel my account" do
  click_link "Account"
  click_link "Cancel Account"
  click_button "Cancel account"
end

When "account for {string} has been approved" do |user_email|
  User.find_by!(email: user_email).account.approve!
end

Then "I should see the page to change account details" do
  response.should have_tag('form') do
    with_tag 'input#account_org_name'
  end
end

# TODO: Move these over to a separate steps file.
Then "I should be able to edit the value of the customers type field" do
  response.should have_xpath("//input[@name='account[profile_attributes][customers_type][]']")
end

Then "I should not be able to edit the value of the customers type field" do
  response.should_not have_xpath("//input[@name='account[profile_attributes][customers_type][]']")
end

Then "I should see the value of the customers type field is {string}" do |value|
  response.should have_xpath("//input[@id='account_profile_attributes_customers_type_#{value.downcase}' and @checked='checked']")
end

Then "{account} should be {state}" do |account, state|
  assert_equal state, account.state
end

Then "I should not be able to cancel account" do
  assert has_no_css? 'a', text: "Cancel account"
end

Then "I should see the notice that I will receive the invoice" do
  assert has_content? "Also note that you have pending invoices. You will receive an email with the exact amount you will be charged on the end of the month"
end

Then "I should see the account details:" do |table|
  table.diff! extract_table('#account-overview', 'tr', 'th,td')
end

Then "{provider} time zone should be {string}" do |provider, time_zone|
  provider.timezone.should be time_zone
end

Then "the provider time zone is {string}" do |time_zone|
  @provider.update!(timezone: time_zone)
end

Then "{account} should be {word}" do |account, type|
  assert account.send("#{type}?"), "Account '#{account.org_name}' is not a #{type}"
end

# TODO: maybe prop type isnt correct here
Given "account/buyer/provider {account} has only one admin {string}" do |account, username|
  to_be_admin = account.users.find_by!(username: username)

  account.users.each do |user|
    user.update(role: :member) unless user == to_be_admin
  end

  to_be_admin.update!(role: :admin)
end
