# frozen_string_literal: true

Given "a buyer {string}" do |name|
  @account = FactoryBot.create(:buyer_account, provider_account: @provider, org_name: name)
  @account.buy! @provider.account_plans.default
end

Given "a buyer {string} of {provider}" do |org_name, provider|
  @account = FactoryBot.create(:buyer_account, provider_account: provider, org_name: org_name)
  @account.buy! provider.account_plans.default
end

Given "{buyer} has {int} application(s)" do |buyer, number|
  buyer.bought_cinstances.destroy_all

  plan = @plan || @product.plans.first
  FactoryBot.create_list(:cinstance, number, user_account: buyer, plan: plan)
end

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

Given "{buyer} is signed up to {plan}" do |buyer, plan|
  buyer.buy!(plan.provider_account.account_plans.default) unless plan.is_a? AccountPlan
  buyer.buy!(plan)
end

Given "a buyer {string} signed up to {plan}" do |org_name, plan|
  @buyer = FactoryBot.create(:buyer_account, provider_account: plan.provider_account,
                                             org_name: org_name)
  @buyer.buy! plan.provider_account.account_plans.default unless plan.is_a? AccountPlan
  @buyer.buy!(plan)
end

Given "a buyer {string} signed up to {provider}" do |account_name, provider|
  step %(an approved buyer "#{account_name}" signed up to provider "#{provider.org_name}")
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

Given "{buyer} has extra fields:" do |buyer, table|
  buyer.extra_fields = table.hashes.first
  buyer.save!
end

Given "{buyer} subscribed to {plan}" do |buyer, plan|
  buyer.buy!(plan)
end

Given "{buyer} {is} subscribed to {product}" do |buyer, subscribed, product|
  if subscribed
    @subscription = buyer.bought_service_contracts.create!(plan: product.service_plans.first)
  else
    buyer.bought_service_contracts.map(&:destroy)
  end
end

Given "the contract of {buyer} with {plan} is approved" do |buyer, plan|
  buyer.contracts.by_plan_id(plan.id).first.accept!
end

Given "{buyer} {plan} contract is {word}" do |buyer, plan, state|
  contract = @buyer.contracts.where(plan_id: plan.id).first!
  contract.update_column(:state, state) # rubocop:disable Rails/SkipsModelValidations
end

Given "{buyer} {plan} contract gets accepted" do |buyer, plan|
  contract = @buyer.contracts.where(plan_id: plan.id).first!
  contract.accept!
end

Given "{buyer} {plan} contract gets suspended" do |buyer, plan|
  contract = @buyer.contracts.where(plan_id: plan.id).first!
  contract.suspend!
end

Given "{buyer} {plan} contract gets resumed" do |buyer, plan|
  contract = @buyer.contracts.where(plan_id: plan.id).first!
  contract.resume!
end

Given "{buyer} uses a custom plan {string}" do |account, name|
  contract = account.provider_account
                    .provided_contracts
                    .find_by(user_account_id: account.id)
  contract.plan.update!(name: name)
  contract.customize_plan!
end

When "{buyer} is approved" do |buyer|
  buyer.approve!
end

When "{provider_or_buyer} changes to {plan}" do |account, plan|
  case plan
  when ApplicationPlan
    account.bought_cinstance.change_plan!(plan)
  when AccountPlan
    # HACK: FIXME: should use something like #bought_account_contract or ## HACK: FIXME: should use something like #bought_account_plan
    account.contracts.first.change_plan!(plan)
  else
    raise ArgumentError, 'Specify the type of plan'
  end
end

# Just an alias, to be more explicit.
Then /^buyer "([^\"]*)" should be (pending|approved|rejected)$/ do |name, state|
  step %(account "#{name}" should be #{state})
end

Then /^I should not see the timezone field$/ do
  assert has_no_xpath? "//*[@id='account_timezone']"
end

Then "{buyer} should be subscribed to {product}" do |buyer, product|
  assert_not_empty buyer.bought_service_contracts.where(service_id: product.id)
end

def signup_form
  find('#signup_form')
end

def login_form
  find('#new_session')
end

When(/^a buyer signs up/) do
  step 'the current domain is foo.3scale.localhost'
  step %(I go to the sign up page)
  step %(I fill in the signup fields as "supertramp")
end

And /^application plan is paid$/ do
  step 'plan "Metal" has a monthly fee of 100'
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

When "the developer tries to log in" do
  username = @buyer.admins.first.username
  set_current_domain("foo.3scale.localhost")
  visit path_to('the login page')
  fill_in('Username or Email', with:  username)
  fill_in('Password', with: "supersecret")
  click_button('Sign in')
end

Then "the developer login attempt fails" do
  assert_current_path "/session"
  assert find_field('Username or Email')
  assert find_field('Password')
  assert find_button('Sign in')
end

When "the buyer is reviewing their account details" do
  visit path_to('the account page')
end

When "the buyer wants to log in" do
  step 'the current domain is foo.3scale.localhost'
  step 'I go to the login page'
end

When "the buyer wants to sign up" do
  step 'the current domain is foo.3scale.localhost'
  step 'I go to the sign up page'
end

Given "the following buyers with service subscriptions signed up to {provider}:" do |provider, table|
  # table is a Cucumber::MultilineArgument::DataTable
  table.map_column!(:plans) { |plans| plans.from_sentence.map{ |plan| Plan.find_by_name!(plan) } }
  table.map_column!(:name) { |name| FactoryBot.create :buyer_account, :provider_account => provider, :org_name => name }
  table.map_headers! { |header| header.to_sym }
  table.hashes.each do |row|
    account = row[:name]
    row[:plans].each do |plan|
      contract = account.buy! plan
      contract.update_attribute(:state,  row[:state]) if row[:state]
    end
  end
end

Given "a buyer {string} signed up to {service}" do |name, service|
  provider = service.account
  step %(a buyer "#{name}" signed up to provider "#{provider.name}")

  plans = service.service_plans
  plan = plans.default_or_first || plans.first
  @buyer.buy! plan
end
