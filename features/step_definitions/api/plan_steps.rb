Then /^I should not see any plans$/ do
  within plans do
    page.should have_css('tbody tr', size: 0)
  end
end

Then /^I should see a (published|hidden) plan "([^"]*)"$/ do |state, name|
  within plans do
    assert has_table_row_with_cells?(name, state)
  end
end

Then /^I should (not )?see plan "([^"]*)"$/ do |negate, name|
  within plans do
    method = negate ? :have_no_css : :have_css
    page.should send(method, 'td', text: name)
  end
end

When /^I follow "([^"]*)" for (plan "[^"]*")$/ do |label, plan|
  step %(I follow "#{label}" within "##{dom_id(plan)}")
end

When /^I select "(.*?)" as default plan$/ do | plan |
  # if React default plan select
  if (select = find(:css, '#default_plan_card .pf-c-select'))
    select.find(:css, '.pf-c-button.pf-c-select__toggle-button').click unless select[:class].include?('pf-m-expanded')
    select.find('.pf-c-select__menu-item', text: plan).click
  else
    select plan
  end
end

Then /^I should not see "(.*?)" in the default plans list$/ do | plan_name |
  within(default_plan) do
    page.should_not have_content(plan_name)
  end
end

Then /^I should see "(.*?)" in the default plans list$/ do | plan_name |
  # if React default plan select
  if (select = find(:css, '#default_plan_card .pf-c-select'))
    select.find(:css, '.pf-c-button.pf-c-select__toggle-button').click unless select[:class].include?('pf-m-expanded')
    select.should have_content(plan_name)
  else
    within(default_plan) do
      page.should have_content(plan_name)
    end
  end
end

def plans
  find(:css, 'table#plans')
end

def default_plan
  find(:css, "select#default_plan")
end

def new_application_plan_form
  find(:css, '#new_application_plan')
end

When(/^the provider creates a plan$/) do
  name = SecureRandom.hex(10)

  step 'I go to the application plans admin page'
  click_on 'Create Application Plan'

  within new_application_plan_form do
    fill_in 'Name', with: name
    fill_in 'System name', with: name

    click_on 'Create Application Plan' # TODO: should be Application Plan
  end

  page.should have_content("Created Application plan #{name}")

  @plan = Plan.find_by_name!(name)
end
