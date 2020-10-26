# frozen_string_literal: true

Then "I should not see any plans" do
  within plans do
    page.should have_css('tbody tr', size: 0)
  end
end

Then "I should see a {published} plan {string}" do |published, name|
  within plans do
    assert table_row_with_cells?(name, published ? 'published' : 'hidden')
  end
end

Then "I {should} see plan {string}" do |visible, name|
  within plans do
    method = visible ? :have_css : :have_no_css
    page.should send(method, 'td', text: name)
  end
end

When "I follow {string} for {plan}" do |label, plan|
  step %(I follow "#{label}" within "##{dom_id(plan)}")
end

When "I select {string} as default plan" do |plan|
  select plan
end

Then "I {should} see {string} in the default plans list" do |plan_name|
  within default_plan do
    method = visible ? :have_content : :have_no_content
    page.should send(method, plan_name)
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

When "the provider creates a plan" do
  name = SecureRandom.hex(10)

  step 'I go to the application plans admin page'
  click_on 'Create Application Plan'

  within new_application_plan_form do
    fill_in 'Name', with: name
    fill_in 'System name', with: name

    click_on 'Create Application Plan' # TODO: should be Application Plan
  end

  page.should have_content("Created Application plan #{name}")

  @plan = Plan.find_by!(name: name)
end
