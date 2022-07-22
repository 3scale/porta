# frozen_string_literal: true

PLANS = /account|service|application/.freeze

Given "the {provider} has following {plan_type} plan(s):" do |provider, plan_type, table|
  transform_application_plans_table(table).hashes.each do |row|
    FactoryBot.create plan_type, row.reverse_merge!(issuer: provider.first_service!)
  end
end

Given "a published service plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :service, :name => plan_name, :issuer => service, :published => true
end

Given "a default published service plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :service, :name => plan_name, :issuer => service, :published => true, :default => true
end

Given "a published application plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :application, :name => plan_name, :issuer => service, :published => true
end

Given "a default published application plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :application, :name => plan_name, :issuer => service, :published => true, :default => true
end

Given(/^the provider has a (default )?free application plan(?: "([^"]*)")?$/) do |default, plan_name|
  @free_application_plan ||= create_plan :application, name: plan_name || 'Copper', issuer: @service, published: true, default: default.present?
end

Given(/^the provider has a(nother|\ second|\ third)? (default )?paid (application|service|account) plan(?: "([^"]*)")?(?: of (\d+) per month)?$/) do |other, default, plan_type, plan_name, cost|
  plan_type_name = (other ? "#{other.strip}_" : '') + plan_type
  return instance_variable_get("@paid_#{plan_type_name}_plan") if instance_variable_defined?("@paid_#{plan_type_name}_plan")

  default_plan_names = {
    'application' => 'Gold',
    'service' => 'Star',
    'account' => 'Premium'
  }
  default_plan_costs = {
    'application' => 100,
    'service' => 10,
    'account' => 1
  }
  plan_name = (plan_name || default_plan_names[plan_type])
  plan = create_plan plan_type.to_sym, name: plan_name, issuer: @service, cost: (cost || default_plan_costs[plan_type]), published: true, default: default.present?
  instance_variable_set("@paid_#{plan_type_name}_plan", plan)
end

Given /^(?:a|an)( default)?( published)? (#{PLANS}) plan "([^"]*)" (?:of|for) (?:provider) "([^"]*)"(?: for (\d+) monthly)?(?: exists)?$/ do |default, published, type, plan_name, domain, cost|
  type ||= :application
  issuer = provider_by_name(domain)
  create_plan type, :name => plan_name, :issuer => issuer, :cost => cost, :default => default, :published => published
end

Given /^(?:a|an)( default)?( published)? (#{PLANS}) plan "([^"]*)" (?:of|for) (?:service) "([^"]*)"(?: for (\d+) monthly)?(?: exists)?$/ do |default, published, type, plan_name, issuer, cost|
  type ||= :application
  issuer = Service.find_by!(name: issuer)
  create_plan type, :name => plan_name, :issuer => issuer, :cost => cost, :default => default, :published => published
end

Given "{buyer} signed up for plan(s) {}" do |buyer, lst|
  lst.each do |name|
    name = name.strip.delete('"')
    sign_up(buyer, name)
  end
end

Given /^the buyer signed up for provider's paid (application|service|account) plan$/ do |plan_type|
  plan = instance_variable_get("@paid_#{plan_type}_plan")
  sign_up(@buyer, plan.name)
end

Given /^the buyer signed up for plan "([^"]*)"$/ do |plan_name|
  sign_up(@buyer, plan_name)
end

Given /^the buyer changed to plan "([^"]*)"$/ do |plan_name|
  plan = Plan.find_by(name: plan_name)
  @buyer.bought_cinstance.change_plan!(plan)
end

Given /^the buyer's (application|service|account) plan contract is (.*)$/ do |plan_type,state|
  plan = instance_variable_get("@paid_#{plan_type}_plan")
  contract = @buyer.contracts.where(plan_id: plan.id).first!
  contract.update_column(:state, state) # rubocop:disable Rails/SkipsModelValidations
end

Given "{plan} is {published}" do |plan, published|
  if published
    plan.publish! unless plan.published?
  else
    plan.hide! unless plan.hidden?
  end
end

Given "{plan} requires approval( of contracts)" do |plan|
  plan.update_attribute :approval_required, true # rubocop:disable Rails/SkipsModelValidations
end

Given /^the application "([^"]*)" of the partner "([^"]*)" has a trial period of (\d+) days?$/  do |application_name, buyer_name, days|
  cinstance = @provider.buyers.where(org_name: buyer_name)
      .first.application_contracts.where(name: application_name).first
  cinstance.trial_period_expires_at = Time.zone.now + days.to_i.days
  cinstance.save!
end

Given(/^I want to change the plan of my application to paid$/) do
  steps %(
    Given the buyer logs in to the provider
    And I go to my application page
    And I follow "Edit #{@application.name}"
    And I follow "Review/Change"
    And I follow "#{@paid_application_plan.name}"
  )
end

Given /^master has an? application plan "([^"]*)"$/ do |plan_name|
  create_plan :application, name: plan_name, issuer: Account.master
end

Then "they can filter plans by name" do
  input = find('#plans_table input[type="search"]')

  input.set('one')
  input.sibling('button').click
  assert_plans_table @plans.by_query('one')

  input.set('last')
  input.sibling('button').click
  assert_plans_table @plans.by_query('last')

  input.set('foooo')
  input.sibling('button').click
  assert_plans_table []

  input.set('')
  input.sibling('button').click
  assert_plans_table @plans
end

And "they can sort plans by name, no. of contracts and state" do
  within plans_table do
    click_on 'Name'
    assert_plans_table @plans.reorder(name: :asc), sort: true

    click_on 'Name'
    assert_plans_table @plans.reorder(name: :desc), sort: true

    click_on 'Contracts'
    assert_plans_table @plans.reorder(contracts_count: :asc), sort: true

    click_on 'Contracts'
    assert_plans_table @plans.reorder(contracts_count: :desc), sort: true

    click_on 'State'
    assert_plans_table @plans.reorder(state: :asc), sort: true

    click_on 'State'
    assert_plans_table @plans.reorder(state: :desc), sort: true
  end
end

def find_action_for_plan(action, plan)
  td = find('td', text: plan.name)
  dropdown = td.sibling('.pf-c-table__action').find('.pf-c-dropdown')
  dropdown.find('.pf-c-dropdown__toggle').click unless dropdown[:class].include? 'pf-m-expanded'

  return nil unless dropdown.has_css?('.pf-c-dropdown__menu-item', text: action)

  dropdown.find('.pf-c-dropdown__menu-item', text: action)
end

Then "an admin can't select the plan as default" do
  select_default_plan @plan
  assert has_content? /not found/i
end

def default_service
  @default_service ||= @provider.default_service
end

def select_default_plan(plan)
  select = find(:css, '#default_plan_card .pf-c-select')
  select.find(:css, '.pf-c-button.pf-c-select__toggle-button').click unless select[:class].include?('pf-m-expanded')
  select.find('.pf-c-select__menu-item', text: plan.name).click
  button = find(:css, '#default_plan_card .pf-c-button[type="submit"]')
  button.click(wait: 5)
end

def delete_plan_from_table_action(plan)
  accept_confirm do
    find_action_for_plan(/delete/i, plan).click
  end
  assert_flash 'The plan was deleted'
  assert_not has_content?(plan.name) # TODO: assert table row not whole content
end

def hide_plan_and_assert(plan)
  find_action_for_plan(/hide/i, plan).click
  assert has_content?("Plan #{plan.name} was hidden.")

  find('td', text: plan.name).sibling('[data-label="State"]', text: /hidden/i)
end

Then "the plan is hidden" do
  assert @plan.reload.hidden?
  assert find_action_for_plan(/publish/i, @plan)
  assert_not find_action_for_plan(/hide/i, @plan)
end

def publish_plan_and_assert(plan)
  find_action_for_plan(/publish/i, plan).click
  assert has_content?("Plan #{plan.name} was published.")

  find('td', text: plan.name).sibling('[data-label="State"]', text: /published/i)
end

Then "the plan is published" do
  assert @plan.reload.published?
  assert_not find_action_for_plan(/publish/i, @plan)
  assert find_action_for_plan(/hide/i, @plan)
end
