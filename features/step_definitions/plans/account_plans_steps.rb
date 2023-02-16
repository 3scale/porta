# frozen_string_literal: true

Then "an admin {is} able to see its account plans" do |visible|
  visit admin_buyers_account_plans_path

  assert_equal visible, section_from_vertical_nav?('Accounts') && subsection_from_vertical_nav?('Accounts', 'Account Plans')
end

When /^an admin selects a (published|hidden) account plan as default$/ do |state|
  @plan = FactoryBot.create(:account_plan, provider: @provider, state: state)

  visit admin_buyers_account_plans_path
  select_default_plan @plan
  assert_equal @plan, @provider.reload.default_account_plan
end

Then "new accounts will subscribe to this plan" do
  visit new_admin_buyers_account_path
  fill_in('Username', with: 'some-buyer')
  fill_in('Email', with: 'buyer@example.com')
  fill_in('Password', with: 'megasecret123')
  fill_in('Organization/Group Name', with: 'Da Group')

  click_on 'Create'

  assert_equal @plan, Account.buyers.last.bought_account_plan
end

When "an admin is in the account plans page" do
  visit admin_buyers_account_plans_path
end

Then "they can add new account plans" do
  click_link 'Create Account plan'
  fill_in('Name', with: 'Basic')
  click_on 'Create Account plan'

  assert_content 'Created Account plan Basic'
  assert current_path, admin_buyers_account_plans_path
end

When /^I customize the account plan$/ do
  click_link "Convert to a Custom Plan"
  wait_for_requests
end

When /^I decustomize the account plan$/ do
  click_button "Remove customization"
end

Then /^I should see the account plan is customized$/ do
  assert has_xpath?("//h3", :text => "Custom Account Plan")
end

Then /^I should not see the account plan is customized$/ do
  assert has_no_xpath?("//h3", :text => "Custom Account Plan")
end

When "an admin selects the action copy of an account plan" do
  @plan = FactoryBot.create(:account_plan, provider: @provider)

  visit admin_buyers_account_plans_path
  find_action_for_plan(/copy/i, @plan).click
end

When "an admin clicks on an account plan" do
  @plan = FactoryBot.create(:account_plan, provider: @provider, name: "Old name")

  visit admin_buyers_account_plans_path
  click_link @plan.name
end

When "a buyer {is} subscribed to the provider using an account plan" do |used|
  @plan = FactoryBot.create(:account_plan, provider: @provider)
  FactoryBot.create(:buyer_account, provider_account: @provider).buy!(@plan) if used
end

Then "an admin can delete it from the account plans page" do
  visit admin_buyers_account_plans_path
  delete_plan_from_table_action(@plan)
end

Then "an admin cannot delete it from the account plans page" do
  visit admin_buyers_account_plans_path
  assert_not find_action_for_plan(/delete/i, @plan)
end

When "an admin hides a plan from the account plans page" do
  @plan = FactoryBot.create(:account_plan, provider: @provider, state: 'published')
  visit admin_buyers_account_plans_path

  hide_plan_and_assert(@plan)
end

When "an admin publishes a plan from the account plans page" do
  @plan = FactoryBot.create(:account_plan, provider: @provider, state: 'hidden')
  visit admin_buyers_account_plans_path

  publish_plan_and_assert(@plan)
end

When "an admin is looking for an account plan" do
  AccountPlan.destroy_all
  FactoryBot.create(:account_plan, provider: @provider, name: 'This is number One')
  FactoryBot.create(:account_plan, provider: @provider, name: 'Now the second one', state: 'published')
  FactoryBot.create(:account_plan, provider: @provider, name: 'Finally the Last')

  plan = FactoryBot.create(:account_plan, provider: @provider, name: 'This has been bought')
  FactoryBot.create(:buyer_account, provider_account: @provider).buy!(plan)
  plan.reset_contracts_counter

  plan2 = FactoryBot.create(:account_plan, provider: @provider, name: 'This has been bought twice!')
  FactoryBot.create_list(:buyer_account, 2, provider_account: @provider).each do |buyer|
    buyer.buy!(plan2)
  end
  plan2.reset_contracts_counter

  @plans = @provider.account_plans
  visit admin_buyers_account_plans_path
  assert_plans_table @plans
end
