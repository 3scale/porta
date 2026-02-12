# frozen_string_literal: true

Given "a buyer {string}" do |name|
  @buyer = @account = FactoryBot.create(:buyer_account, provider_account: @provider, org_name: name)
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
  @buyer = pending_buyer(provider, account_name)
  @buyer.approve! unless @buyer.approved?
end

Given "a pending buyer {string} signed up to {provider}" do |account_name, provider|
  pending_buyer(provider, account_name)
end

# Create a group of buyer accounts subscribed to one or more service plans

# Given the following buyers with service subscriptions signed up to the provider:
#   | Buyer  | Plans      | State   |
#   | Ben    | Basic, Pro | Pending |
#   | Bender | Basic      |         |
Given "the following buyers with service subscriptions signed up to {provider}:" do |provider, table|
  transform_service_contract_table(table, provider)

  table.hashes.each do |row|
    row[:plans].each do |plan|
      contract = row[:buyer].buy!(plan)
      contract.update_attribute(:state, row[:state]) if row[:state] # rubocop:disable Rails/SkipsModelValidations
    end
  end
end

def pending_buyer(provider, account_name)
  # TODO: Refactor this method into a factory
  buyer = FactoryBot.create(:buyer_account, :provider_account => provider,
                  :org_name => account_name,
                  :buyer => true)
  buyer.buy! provider.account_plans.default

  buyer.make_pending!
  assert buyer.pending?

  buyer
end

Given "an approved buyer {string} signed up to {provider}" do |account_name, provider|
  @buyer = pending_buyer(provider, account_name)
  @buyer.approve! unless @buyer.approved?
end

Given "a rejected buyer {string} signed up to {provider}" do |account_name, provider|
  account = pending_buyer(provider, account_name)
  account.reject!
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

Given "{buyer} has no applications" do |buyer|
  buyer.bought_cinstances.destroy_all
end

Given "{buyer} has email {string}" do |buyer, email|
  buyer.admins.first.update!(email: email)
end

Given "{buyer} has no live applications" do |buyer|
  buyer.bought_cinstances.each &:suspend!
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
  set_current_domain 'foo.3scale.localhost'
  visit signup_path
  fill_in_signup_fields_as 'supertramp'
end

When(/^I should be warned to complete my signup$/) do
  assert_text "To complete your signup, please fill in your credit card details."
end

When(/^as a developer$/) do
  set_current_domain 'foo.3scale.localhost'
end

When "the developer tries to log in" do
  username = @buyer.admins.first.username
  set_current_domain("foo.3scale.localhost")
  visit path_to('the login page')
  fill_in('Username or Email', with:  username)
  fill_in('Password', with: "superSecret1234#")
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
  set_current_domain 'foo.3scale.localhost'
  visit login_path
end

When "the buyer wants to sign up" do
  set_current_domain 'foo.3scale.localhost'
  visit signup_path
end

Given "a buyer {string} signed up to {service}" do |name, service|
  @buyer = pending_buyer(service.account, name)
  @buyer.approve! unless @buyer.approved?

  plans = service.service_plans
  plan = plans.default_or_first || plans.first
  @buyer.buy! plan
end
