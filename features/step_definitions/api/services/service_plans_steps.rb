# frozen_string_literal: true

When /^an admin selects a (hidden|published) service plan as default$/ do |state|
  @plan = FactoryBot.create(:service_plan, issuer: default_service, state: state)

  visit admin_service_service_plans_path(default_service)
  select_default_plan @plan
  assert_equal @plan, default_service.reload.default_service_plan
end

Then "any new application of that product will be subscribed using this plan" do
  FactoryBot.create(:buyer_account, provider_account: @provider)
  FactoryBot.create(:application_plan, issuer: default_service)

  visit new_admin_service_application_path(default_service)
  fill_in_new_application_form
  click_on 'Create application'

  assert_equal @plan, Cinstance.last.buyer_account.bought_service_contracts.last.plan
end

When "an admin is in the service plans page" do
  visit admin_service_service_plans_path(default_service)
end

Then "they can add new service plans" do
  click_link 'Create Service plan'
  fill_in('Name', with: 'Basic')
  click_on 'Create Service plan'

  assert_content 'Created Service plan Basic'
  assert current_path, admin_service_service_plans_path(default_service)
end

When "an admin selects the action copy of a service plan" do
  @plan = FactoryBot.create(:service_plan, issuer: default_service)

  visit admin_service_service_plans_path(default_service)
  find_action_for_plan(/copy/i, @plan).click
end

When "an admin clicks on a service plan" do
  @plan = FactoryBot.create(:service_plan, issuer: default_service, name: "Old name")

  visit admin_service_service_plans_path(default_service)
  click_link @plan.name
end

When "a service plan {is} being used in an(y) application(s)" do |used|
  @plan = FactoryBot.create(:service_plan, service: default_service)
  FactoryBot.create(:buyer_account, provider_account: @provider).bought_service_contracts.create!(plan: @plan) if used
end

Then "an admin can delete it from the service plans page" do
  visit admin_service_service_plans_path(default_service)
  delete_plan_from_table_action(@plan)
end

Then "an admin cannot delete it from the service plans page" do
  visit admin_service_service_plans_path(default_service)
  assert_not find_action_for_plan(/delete/i, @plan)
end

When "an admin hides a plan from the service plans page" do
  @plan = FactoryBot.create(:service_plan, issuer: default_service, state: 'published')
  visit admin_service_service_plans_path(default_service)

  hide_plan_and_assert(@plan)
end

When "an admin publishes a plan from the service plans page" do
  @plan = FactoryBot.create(:service_plan, issuer: default_service, state: 'hidden')
  visit admin_service_service_plans_path(default_service)
  publish_plan_and_assert(@plan)
end

When "an admin is looking for a service plan" do
  ServicePlan.destroy_all
  @plan_a = FactoryBot.create(:service_plan, issuer: default_service, name: 'This is number One')
  @plan_b = FactoryBot.create(:service_plan, issuer: default_service, name: 'Now the second one', state: 'published')
  @plan_c = FactoryBot.create(:service_plan, issuer: default_service, name: 'Finally the Last', state: 'published')

  FactoryBot.create(:buyer_account, provider_account: @provider, org_name: 'Org 1').bought_service_contracts.create!(plan: @plan_a)
  FactoryBot.create(:buyer_account, provider_account: @provider, org_name: 'Org 2').bought_service_contracts.create!(plan: @plan_b)

  visit admin_service_service_plans_path(default_service)

  assert_plans_table [@plan_a, @plan_b, @plan_c]
end

Then "an admin {is} able to see its service plans" do |visible|
  visit admin_service_path(default_service)

  assert_equal visible, section_from_vertical_nav?('Subscriptions') && subsection_from_vertical_nav?('Subscriptions', 'Service Plans')
end

Given "a service plan has been deleted" do
  @plan = FactoryBot.create(:service_plan, issuer: default_service)

  visit admin_service_service_plans_path(default_service)
  @plan.destroy
end
