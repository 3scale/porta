# frozen_string_literal: true

When /^an admin selects a(?:n)? (hidden )?application plan as default$/ do |hidden|
  plan_type = hidden ? :application_plan : :published_plan

  @plan = FactoryBot.create(plan_type, issuer: default_service)

  visit admin_service_application_plans_path(default_service)
  select_default_plan @plan
  assert_equal @plan, default_service.reload.default_application_plan
end

Then "any new application will use this plan" do
  FactoryBot.create(:buyer_account, provider_account: @provider)

  visit new_provider_admin_application_path
  pf4_select_first(from: 'Account')
  pf4_select_first(from: 'Product')
  find('.pf-c-form__label', text: 'Name').sibling('input').set('My App')
  find('.pf-c-form__label', text: 'Description').sibling('input').set('This is some kind of application')
  click_on 'Create application'

  assert_equal @plan, Cinstance.last.plan
end

When "an admin is in the application plans page" do
  visit admin_service_application_plans_path(default_service)
end

Then "they can add new application plans" do
  click_link 'Create application plan'
  fill_in('Name', with: 'Basic')
  click_on('Create application plan', wait: 5)

  assert_content /created application plan basic/i
  assert current_path, admin_service_application_plans_path(default_service)
end

When "an admin selects the action copy of an application plan" do
  @plan = FactoryBot.create(:application_plan, issuer: default_service)

  visit admin_service_application_plans_path(default_service)
  find_action_for_plan(/copy/i, @plan).click
end

When "an admin clicks on an application plan" do
  @plan = FactoryBot.create(:application_plan, issuer: default_service, name: "Old name")

  visit admin_service_application_plans_path(default_service)
  click_link @plan.name
end

Then "an admin can delete it from the application plans page" do
  visit admin_service_application_plans_path(default_service)
  delete_plan_from_table_action(@plan)
end

When "an application plan {is} being used in an(y) application(s)" do |used|
  @plan = FactoryBot.create(:application_plan, service: default_service)
  FactoryBot.create(:cinstance, service: default_service, plan: @plan) if used

  assert_equal used, @plan.reload.contracts_count.positive?
end

Then "an admin cannot delete it from the application plans page" do
  visit admin_service_application_plans_path(default_service)
  assert_not find_action_for_plan(/delete/i, @plan)
end

When "an admin hides a plan from the application plans page" do
  @plan = FactoryBot.create(:published_plan, issuer: default_service)
  visit admin_service_application_plans_path(default_service)

  hide_plan_and_assert(@plan)
end

When "an admin publishes a plan from the application plans page" do
  @plan = FactoryBot.create(:application_plan, issuer: default_service)
  visit admin_service_application_plans_path(default_service)
  publish_plan_and_assert(@plan)
end

Then "a buyer {will} be able to use it for their applications" do |will|
  assert_equal will, @plan.service.application_plans.not_custom.published.include?(@plan)
end

When "an admin is looking for an application plan" do
  ApplicationPlan.destroy_all
  FactoryBot.create(:application_plan, issuer: default_service, name: 'This is number One')
  FactoryBot.create(:application_plan, issuer: default_service, name: 'Now the second one')
  FactoryBot.create(:application_plan, issuer: default_service, name: 'Finally the Last')

  FactoryBot.create(:buyer_account, provider_account: @provider).buy!(
    FactoryBot.create(:application_plan, issuer: default_service, name: 'This has been bought')
  )

  plan = FactoryBot.create(:application_plan, issuer: default_service, name: 'This has been bought twice!')
  FactoryBot.create_list(:buyer_account, 2, provider_account: @provider).each do |buyer|
    buyer.buy!(plan)
  end

  @plans = default_service.application_plans
  @plans.last(3).each(&:publish!)

  visit admin_service_application_plans_path(default_service)
  assert_plans_table @plans
end

#TODO: FIXME: rename to: application plan
Given /^a (published|hidden) plan "([^"]*)" of provider "([^"]*)"$/ do |state, plan_name, account_name|
  raise %(There is already one plan called "#{plan_name}". For simplicity in cucumber features, the plan name must be globally unique) if ApplicationPlan.find_by(name: plan_name)

  account = Account.find_by!(org_name: account_name)
  plan = FactoryBot.create(:application_plan, :name => plan_name, :issuer => account.default_service)
  plan.publish! if state == 'published'
end

# TODO: make a general, attribute setting step for plan?
Given "{plan} has trial period of {int} days" do |plan, days|
  plan.update!(trial_period_days: days)
end

# TODO: make a general, attribute setting step for plan?
Given "{plan} has monthly fee of {int}" do |plan, fee|
  plan.update!(cost_per_month: fee)
end

# TODO: make a general, attribute setting step for plan?
Given "{plan} has setup fee of {int}" do |plan, fee|
  plan.update!(setup_fee: fee)
end

Given "{plan} has {string} {enabled}" do |plan, feature_name, enabled|
  feature = plan.service.features.find_or_create_by(name: feature_name)
  assert_not_nil feature

  if enabled
    plan.features << feature
  else
    plan.features.delete(feature)
  end

  plan.save!
end

Given "{provider} has no published application plans" do |provider|
  provider.application_plans.each(&:hide!)
end

Given "{plan} has applications" do |plan|
  FactoryBot.create(:cinstance, :application_id => SecureRandom.hex(8), :plan => plan)
end

When /^I change application plan to "([^"]*)"$/ do |name|
  plan = ApplicationPlan.find_by(name: name)
  current_account.bought_cinstance.change_plan!(plan)
end

Then "{plan} should be published" do |plan|
  assert plan.published?
end

Then "{plan} should be hidden" do |plan|
  assert plan.hidden?
end

Then /^I should see the monthly fee is "([^"]*)"$/ do |fee|
  assert(all('tr').any? do |tr|
    tr.has_css?('th', :text => "Monthly fee") &&
    tr.has_css?('td', :text => fee)
  end)
end

Then /^I should see the plan details widget$/ do
  assert has_xpath?("//h3", :text => /Plan/)
end

Then /^I should not see the change plan widget$/ do
  assert has_no_xpath?("//h3", :text => "Change Plan")
end

Then /^I should see the app plan is "([^"]*)"$/ do |plan|
  assert has_xpath?("//h3", :text => "Plan: #{plan}")
end

Then /^I should see the app plan is customized$/ do
  assert has_xpath?("//h3", :text => "Custom Application Plan")
end

Then /^I should be able to customize the plan$/ do
  should have_link("Convert to a Custom Plan")
end

Then "the application plan {string} should be deleted" do |name|
  assert_content "The plan was deleted", wait: 10
  step(%(I should not see plan "#{name}"))
end

And "an application plan that is not default" do
  @plan = FactoryBot.create(:application_plan, name: "Magic", issuer: default_service)
  assert_not @plan.master?
end

Given "an application plan has been deleted" do
  @plan = FactoryBot.create(:application_plan, issuer: default_service)

  visit admin_service_application_plans_path(default_service)
  @plan.destroy
end

When /^I change the app plan to "([^"]*)"$/ do |plan|
  pf4_select(plan, from: 'Change plan')
  click_button 'Change'
end

When /^I customize the app plan$/ do
  click_link 'Convert to a Custom Plan'
end

When /^I decustomize the app plan$/ do
  click_button 'Remove customization'
end

Then /^I should not be able to pick a plan$/ do
  should_not have_link('Review/Change')
end

Then /^I should not see any plans$/ do
  within plans_table do
    page.should have_css('tbody tr', size: 0)
  end
end

Then /^I should see a (published|hidden) plan "([^"]*)"$/ do |state, name|
  within plans_table do
    assert has_table_row_with_cells?(name, state)
  end
end

Then /^I should (not )?see plan "([^"]*)"$/ do |negate, name|
  within plans_table do
    method = negate ? :have_no_css : :have_css
    page.should send(method, 'td', text: name)
  end
end

When "I follow {string} for {plan}" do |label, plan|
  step %(I follow "#{label}" within "##{dom_id(plan)}")
end

def plans_table
  if page.has_css?('#plans_table .pf-c-table')
    find('#plans_table .pf-c-table')
  else
    ThreeScale::Deprecation.warn "Detected outdated plans list, pending migration to PF4 React"
    find(:css, '#plans')
  end
end

def default_plan_select
  find(:css, "select#default_plan")
end

def new_application_plan_form
  find(:css, '#new_application_plan')
end

When(/^the provider creates a plan$/) do
  name = SecureRandom.hex(10)

  step 'I go to the application plans admin page'
  click_on 'Create application plan'

  within new_application_plan_form do
    fill_in 'Name', with: name
    fill_in 'System name', with: name

    click_on 'Create application plan'
  end

  page.should have_content("Created Application plan #{name}")

  @plan = Plan.find_by!(name: name)
end

Then "a copy of the plan is added to the list" do
  steps %(
    Then I should see "Plan copied."
  )
  assert_flash "#{@plan.name} (copy)"
end

Then "they can edit its details" do
  new_name = 'New name'

  fill_in('Name', with: new_name)
  find('.pf-c-button[type="submit"]').click

  assert_equal new_name, @plan.reload.name
end
