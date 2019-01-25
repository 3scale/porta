Given /^a buyer "([^\"]*)" have not signed up to plan "([^\"]*)"$/ do |buyer_name, plan_name|
  # do nothing. I should not be signed up to plan
  # if getting too paranoid about loose assumption you could:
  # find buyer and remove plan in case it exists :-)
end

When /^(?:a )?buyer "(.+?)" with email "(.+?)" signs up to (provider ".+?")$/ do |name, email, provider|
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

Given /^a buyer "([^"]*)" of (provider "[^"]*")$/ do |org_name, provider|
  account = FactoryBot.create(:buyer_account, :provider_account => provider,
                    :org_name => org_name)
  account.buy! provider.account_plans.default
end

Given /^a buyer "([^"]*)" signed up to plan "([^"]*)"$/ do |buyer, plan|
  ActiveSupport::Deprecation.warn("This step is deprecated. You have to specify which plan (application, service, account) to buy.")
  step %{a buyer "#{buyer}" signed up to application plan "#{plan}"}
end

Given /^a buyer "([^"]*)" signed up to ((?:application|service) plan "[^"]*")$/ do |org_name, plan|
  account = FactoryBot.create(:buyer_account,
                    :provider_account => plan.provider_account,
                    :org_name => org_name)
  account.buy! plan.provider_account.account_plans.default
  account.buy!(plan)
end

Given /^a buyer without billing address "([^"]*)" signed up to ((?:application|service) plan "[^"]*")$/ do |org_name, plan|
  account = FactoryBot.create(:buyer_account_without_billing_address,
                    :provider_account => plan.provider_account,
                    :org_name => org_name)
  account.buy! plan.provider_account.account_plans.default
  account.buy!(plan)
end

Given /^a buyer "([^"]*)" signed up to (account plan "[^"]*")$/ do |org_name, plan|
  account = FactoryBot.create(:buyer_account,
                    :provider_account => plan.provider_account,
                    :org_name => org_name)
  account.buy! plan
end

Given /^a buyer "([^"]*)" with application ID "([^"]*)" signed up to (plan "[^"]*")$/ do |org_name, app_id, plan|
  account = FactoryBot.create(:buyer_account, :provider_account => plan.provider_account,
                                    :org_name => org_name)
  account.buy! plan.provider_account.account_plans.default

  Cinstance.create!(:user_account => account, :plan => plan,
                    :application_id => app_id)
end

Given /^a buyer "([^\"]*)" signed up to provider "([^\"]*)"$/ do |account_name, provider_account_name|
  step %(an approved buyer "#{account_name}" signed up to provider "#{provider_account_name}")
end

Given(/^a buyer signed up to the provider$/) do
  step %(an approved buyer "John" signed up to provider "#{@provider.domain}")
  @buyer = Account.find_by_org_name!('John')
  step 'buyer "John" has application "TimeMachine"'
  @application = @buyer.application_contracts.find_by_name!('TimeMachine')
end

Given /^a freshly created buyer "([^\"]*)" signed up to (provider "[^\"]*")$/ do |account_name, provider|
  buyer = FactoryBot.create(:buyer_account, :provider_account => provider,
                  #buyer = FactoryBot.create(:account, :provider_account => provider,
                  :org_name => account_name,
                  :buyer => true)
  buyer.buy! provider.account_plans.default
end

Given /^a pending buyer "([^\"]*)" signed up to provider "([^\"]*)"$/ do |account_name, provider_account_name|
  step %(a freshly created buyer "#{account_name}" signed up to provider "#{provider_account_name}")

  account = Account.find_by_org_name!(account_name)

  account.make_pending!
  assert account.pending?
end

Given /^an approved buyer "([^\"]*)" signed up to provider "([^\"]*)"$/ do |account_name, provider_account_name|
  step %(a pending buyer "#{account_name}" signed up to provider "#{provider_account_name}")

  @buyer = Account.find_by_org_name!(account_name)
  @buyer.approve!
end

Given /^a rejected buyer "([^\"]*)" signed up to provider "([^\"]*)"$/ do |account_name, provider_account_name|
  step %(a pending buyer "#{account_name}" signed up to provider "#{provider_account_name}")

  account = Account.find_by_org_name!(account_name)
  account.reject!
end

Given /^a buyer "([^"]*)" signed up to plan "([^"]*)" without providing description$/ do |account_name, plan_name|
  step %(a buyer "#{account_name}" signed up to application plan "#{plan_name}")

  # The description is blank already, this is here just to protect us from the future's
  # changes.

  account = Account.find_by_org_name!(account_name)
  assert account.bought_cinstance.description.blank?
end

Given /^these buyers signed up to provider "([^"]*)"$/ do |provider_name, table|
  table.raw.each do |row|
    step %(a buyer "#{row[0]}" signed up to provider "#{provider_name}")
  end
end

Given /^these buyers signed up to plan "([^"]*)"$/ do |plan_name, table|
  table.raw.each do |row|
    step %(a buyer "#{row[0]}" signed up to application plan "#{plan_name}")
  end
end

Given /^these buyers signed up to plan "([^"]*)":$/ do |plan_name, table|
  #TODO: dry this with account_steps Given provider "([^\"]*)" has the following buyers:
  table.hashes.each do |hash|
    step %{a buyer "#{hash['Name']}" signed up to application plan "#{plan_name}"}

    buyer = Account.buyers.find_by_org_name!(hash['Name'])

    buyer.update_attribute :state, hash['State'] if hash['State']
    if hash['Created at']
      cr_at = Chronic.parse hash['Created at']
      buyer.update_attribute :created_at, cr_at
      buyer.bought_cinstance.update_attribute :created_at, cr_at
    end
  end
end

Given /^buyer "([^"]*)" has ([0-9\.]+) in credit$/ do |buyer_name, credit|
  buyer_account = Account.find_by_org_name!(buyer_name)
  buyer_account.update_attributes!(:buyerbalance => credit)
  buyer_account.bought_cinstances.each(&:pay_fixed_cost!)
end

Given /^there are no buyers of (provider "[^"]*")$/ do |provider_account|
  provider_account.buyer_accounts.destroy_all
end

# TODO: these steps should be moved over to more appropriately named step definition files.

When /^I follow the link to create a new buyer account$/ do
  click_link "Create new account"
end

When /^(buyer "[^\"]*") is approved$/ do |buyer|
  buyer.approve!
end

Then /^there should be no buyer "([^"]*)"$/ do |name|
  assert_nil Account.buyers.find_by_org_name(name)
end

Then /^there should be a buyer "([^"]*)"$/ do |name|
  assert_not_nil Account.buyers.find_by_org_name(name)
end

# Just an alias, to be more explicit.
Then /^buyer "([^\"]*)" should be (pending|approved|rejected)$/ do |name, state|
  step %(account "#{name}" should be #{state})
end

Then /^(buyer "[^"]*") should be signed up to (plan "[^"]*")$/ do |buyer, plan|
  assert plan.bought_by?(buyer)
end

Then /^I should not see the timezone field$/ do
  assert has_no_xpath? "//*[@id='account_timezone']"
end


Given('the provider has a buyer') do
  step %'the current domain is #{@provider.domain}'

  visit signup_path

  user = FactoryBot.build_stubbed(:user)

  within signup_form do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'supersecret'
    fill_in 'Password confirmation', with: 'supersecret'
    fill_in 'Username', with: user.email

    fill_in 'Organization/Group Name', with: 'buyer'

    click_on 'Sign up'
  end

  page.should have_content('Thank you')
  page.should have_content('We have sent you an email to confirm your email address.')

  email = open_email(user.email, with_subject: "#{@provider.domain} API account confirmation")
  click_first_link_in_email(email)

  within login_form do
    fill_in 'Username', with: user.email
    fill_in 'Password', with: 'supersecret'

    click_on 'Sign in'
  end

  page.should have_content('Signed in successfully')

  @buyer = @provider.buyers.last!
end

def signup_form
  find('#signup_form')
end

def login_form
  find('#new_session')
end

When(/^the buyer has simple API key$/) do
  @buyer.bought_cinstance.update_column(:user_key, 'simple-api-key')
end

And(/^has a buyer with (application|service) plan/) do |plan|
  step %(provider "#{@provider.domain}" has "service_plans" switch allowed)
  step %(a default service of provider "#{@provider.domain}" has name "API")
  if plan == 'service'
    step 'a service plan "Gold" for service "API" exists'
    step 'a buyer "Alexander" signed up to service plan "Gold"'
  else
    step 'a application plan "Metal" of provider "foo.example.com"'
    step 'a buyer "Alexander" signed up to application plan "Metal"'
  end
end

When(/^a buyer signs up/) do
  step 'the current domain is foo.example.com'
  step %(I go to the sign up page)
  step %(I fill in the signup fields as "supertramp")
end

And /^application plan is paid$/ do
  step 'plan "Metal" has monthly fee of 100'
end

When(/^the buyer logs in$/) do
  steps %(
    And the current domain is foo.example.com
    And I go to the login page
    And I fill in "Username" with "Alexander"
    And I fill in "Password" with "supersecret"
    And I press "Sign in"
    And I should be logged in as "Alexander"
  )
end

When(/^the buyer logs in to the provider$/) do
  steps %(
    When the current domain is #{@provider.domain}
    And I go to the login page
    And I fill in "Username" with "#{@buyer.admins.first.username}"
    And I fill in "Password" with "supersecret"
    And I press "Sign in"
    And I should be logged in as "#{@buyer.admins.first.username}"
  )
end

When(/^I should be warned to complete my signup$/) do
  step 'I should see "To complete your signup, please fill in your credit card details."'
end

When(/^as a developer$/) do
  step 'the current domain is foo.example.com'
end
