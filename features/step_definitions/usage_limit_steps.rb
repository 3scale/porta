# frozen_string_literal: true

Given "an usage limit on {plan} for metric {string} with period {word} and value {int}" do |plan, metric_name, period, value|
  metric = plan.metrics.find_by!(system_name: metric_name)
  ul = metric.usage_limits.new period: period, value: value
  ul.plan = plan
  ul.save!
end

Then "I should see hourly usage limit of {int} for {metric}" do |value, metric|
  within "##{dom_id(metric)}_slot #usage_limits_table" do
    assert table_row_with_cells?('1 hour', value)
  end
end

Then "I should see a usage limit of {int} for {metric_on_application_plan} per {string}" do |value, metric, period|
  within "##{dom_id(metric)}_slot #usage_limits_table" do
    assert table_row_with_cells?(period, value)
  end
end

def hour_selector
  XPath.descendant(:td)[XPath.text.n.contains('1 hour')]
end

def usage_limits_table(metric)
  "##{dom_id(metric)}_slot #usage_limits_table"
end

def assert_metric_within_usage_limits(metric)
  within usage_limits_table(metric) do
    assert_selector :xpath, hour_selector
  end
end

def refute_metric_within_usage_limits(metric)
  begin
    within usage_limits_table(metric) do
      assert_no_selector :xpath, hour_selector
    end
  rescue Capybara::ElementNotFound
    # and that's OK! it should not exist anyway
  end
end

Then "I should see hourly usage limit for {metric}" do |metric|
  assert_metric_within_usage_limits(metric)
end

Then "I should see hourly usage limit for {metric_on_application_plan}" do |metric|
  assert_metric_within_usage_limits(metric)
end

Then "I should not see hourly usage limit for {metric}" do |metric|
  refute_metric_within_usage_limits(metric)
end

Then "I should not see hourly usage limit for {metric_on_application_plan}" do |metric|
  refute_metric_within_usage_limits(metric)
end

Then "{plan} should have a usage limit of {int} for metric {string} per {string}" do |plan, value, metric_name, period|
  wait_for_requests
  metric = plan.service.metrics.find_by!(system_name: metric_name)
  assert_not_nil plan.usage_limits.find_by(metric_id: metric.id, period: period, value: value)
end

Then "{plan} should not have hourly usage limit for metric {string}" do |plan, metric_name|
  metric = plan.metrics.find_by!(system_name: metric_name)
  assert_nil plan.usage_limits.find_by(metric_id: metric.id, period: 'hour')
end

When "I {word} {string} for the hourly usage limit for {string}" do |action, label, metric|
  usage_limit = metric.usage_limits.find_by!(period: 'hour')
  step %(I #{action} "#{label}" within "##{dom_id(usage_limit)}")
end

When "I {word} {string} for the hourly usage limit for {metric_on_application_plan}" do |action, label, metric|
  usage_limit = metric.usage_limits.find_by!(period: 'hour')
  step %(I #{action} "#{label}" within "##{dom_id(usage_limit)}")
end

When "I follow {string} within usage limits panel for {metric_on_application_plan}" do |label, metric|
  step %(I follow "#{label}" within "##{dom_id(metric)}_slot")
end

def metrics
  find(:css, '#metrics')
end

def plans
  find(:css, '#plans')
end

And "limits hits of that plan to {int}" do |number|
  visit_edit_plan(@plan)

  within metrics do
    click_on 'Edit limits of Hits'
    click_on 'New usage limit'
  end

  within '#new_usage_limit' do
    fill_in 'Max. value', with: number
    click_on 'Create usage limit'
  end

  page.should have_content 'Usage Limit has been created'
end


Then "the plan {should} have visible usage limits" do |should_have|
  @plan.should be
  @plan.usage_limits.visible.count.should be.send(should_have ? :> : :==, 0)
end

def visit_edit_plan(plan)
  assert plan

  step %(I go to the application plans admin page)

  plan_name = plan.name
  within plans do
    click_on "Edit Application plan '#{plan_name}'"
  end

  page.should have_css('h1', text: "Application Plan #{plan_name}")
end
