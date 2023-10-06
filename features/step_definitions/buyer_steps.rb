# frozen_string_literal: true

When "(a )buyer {string} with email {string} signs up to {provider}" do |name, email, provider|
  buyer = FactoryBot.build(:buyer_account, :provider_account => provider,
                        :org_name => name, :state => :created)
  buyer.users.each do |user|
    user.email = email
    user.signup_type = :new_signup
  end

  buyer.save!
  buyer.make_pending!

  buyer.buy! provider.account_plans.default
end

Given "a buyer {string} of {provider}" do |org_name, provider|
  account = FactoryBot.create(:buyer_account, :provider_account => provider,
                    :org_name => org_name)
  account.buy! provider.account_plans.default
end

Given "a buyer {string} signed up to {plan}" do |org_name, plan|
  account = FactoryBot.create(:buyer_account,
                    :provider_account => plan.provider_account,
                    :org_name => org_name)
  account.buy! plan.provider_account.account_plans.default unless plan.is_a? AccountPlan
  account.buy!(plan)
end

Given /^a buyer "([^\"]*)" signed up to provider "([^\"]*)"$/ do |account_name, provider_account_name|
  step %(an approved buyer "#{account_name}" signed up to provider "#{provider_account_name}")
end

Given(/^a buyer signed up to the provider$/) do
  org_name = 'John'
  app_name = 'My App'

  step %(an approved buyer "#{org_name}" signed up to provider "#{@provider.internal_domain}")
  step %(buyer "#{org_name}" has application "#{app_name}")

  @buyer = @provider.buyer_accounts.find_by!(org_name: org_name)
  @application = @buyer.application_contracts.find_by!(name: app_name)
end

Given "a pending buyer {string} signed up to {provider}" do |account_name, provider|
  buyer = FactoryBot.create(:buyer_account, :provider_account => provider,
                  :org_name => account_name,
                  :buyer => true)
  buyer.buy! provider.account_plans.default

  buyer.make_pending!
  assert buyer.pending?
end

Given "an approved buyer {string} signed up to {provider}" do |account_name, provider|
  step %(a pending buyer "#{account_name}" signed up to provider "#{provider.org_name}")

  @buyer = provider.buyer_accounts.find_by!(org_name: account_name)
  @buyer.approve! unless @buyer.approved?
end

Given "a rejected buyer {string} signed up to {provider}" do |account_name, provider|
  step %(a pending buyer "#{account_name}" signed up to provider "#{provider.org_name}")

  account = provider.buyer_accounts.find_by!(org_name: account_name)
  account.reject!
end

Given /^these buyers signed up to provider "([^"]*)"$/ do |provider_name, table|
  table.raw.each do |row|
    step %(a buyer "#{row[0]}" signed up to provider "#{provider_name}")
  end
end

When /^I follow the link to create a new buyer account$/ do
  click_link "Create new account"
end

When "{buyer} is approved" do |buyer|
  buyer.approve!
end

# Just an alias, to be more explicit.
Then /^buyer "([^\"]*)" should be (pending|approved|rejected)$/ do |name, state|
  step %(account "#{name}" should be #{state})
end

Then /^I should not see the timezone field$/ do
  assert has_no_xpath? "//*[@id='account_timezone']"
end

def signup_form
  find('#signup_form')
end

def login_form
  find('#new_session')
end

And(/^has a buyer with (application|service) plan/) do |plan|
  step %(provider "#{@provider.internal_domain}" has "service_plans" switch allowed)
  step %(a default service of provider "#{@provider.internal_domain}" has name "API")
  if plan == 'service'
    step 'a service plan "Gold" for service "API" exists'
    step 'a buyer "Alexander" signed up to service plan "Gold"'
  else
    step 'a application plan "Metal" of provider "foo.3scale.localhost"'
    step 'a buyer "Alexander" signed up to application plan "Metal"'
  end
  @buyer = @provider.buyer_accounts.find_by!(org_name: 'Alexander')
end

When(/^a buyer signs up/) do
  step 'the current domain is foo.3scale.localhost'
  step %(I go to the sign up page)
  step %(I fill in the signup fields as "supertramp")
end

And /^application plan is paid$/ do
  step 'plan "Metal" has monthly fee of 100'
end

When(/^the buyer logs in to the provider$/) do
  username = @buyer.admins.first.username
  steps %(
    When the current domain is #{@provider.external_domain}
    And I go to the login page
    And I fill in "Username" with "#{username}"
    And I fill in "Password" with "supersecret"
    And I press "Sign in"
    And I should be logged in as "#{username}"
  )
  @current_user = User.find_by!(username: username)
end

When(/^I should be warned to complete my signup$/) do
  step 'I should see "To complete your signup, please fill in your credit card details."'
end

When(/^as a developer$/) do
  step 'the current domain is foo.3scale.localhost'
end

When "the buyer is reviewing their account details" do
  visit path_to('the account page')
end

Given "a buyer signed up to a provider" do
  steps %(
    Given a provider exists
    And the provider has a default paid application plan
    And a buyer signed up to the provider
  )
end

Given "a buyer logged in to a provider" do
  steps %(
    Given a buyer signed up to a provider
    And the buyer logs in to the provider
  )
end

Given "a buyer logged in to a provider using SSO" do
  steps %(
    Given Provider has setup RH SSO
    And As a developer, I login through RH SSO
    Given the Oauth2 user has all the required fields
    When I authenticate by Oauth2
  )
end

When "the buyer wants to sign up" do
  step 'the current domain is foo.3scale.localhost'
  step 'I go to the sign up page'
end
