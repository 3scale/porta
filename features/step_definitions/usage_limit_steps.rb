Given /^an usage limit on (.*?plan "[^"]*") for metric "([^"]*)" with period ([a-z]+) and value (\d+)$/ do |plan, metric_name, period, value|
  metric = plan.metrics.find_by_system_name!(metric_name)
  ul = metric.usage_limits.new :period => period, :value => value
  ul.plan = plan
  ul.save!
end

Then /^I should see hourly usage limit of (\d+) for (metric "[^"]*")$/ do |value, metric|
  within "##{dom_id(metric)}_slot #usage_limits_table" do
    assert has_table_row_with_cells?('1 hour', value)
  end
end

Then /^I should see a usage limit of (\d+) for (metric "[^"]*" on application plan "[^"]*") per "(.+?)"$/ do |value, metric, period|
  within "##{dom_id(metric)}_slot #usage_limits_table" do
    assert has_table_row_with_cells?(period, value)
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

Then /^I should see hourly usage limit for (metric "[^"]*")$/ do |metric|
  assert_metric_within_usage_limits(metric)
end

Then /^I should see hourly usage limit for (metric "[^"]*" on application plan "[^"]*")$/ do |metric|
  assert_metric_within_usage_limits(metric)
end

Then /^I should not see hourly usage limit for (metric "[^"]*")$/ do |metric|
  refute_metric_within_usage_limits(metric)
end

Then /^I should not see hourly usage limit for (metric "[^"]*" on application plan "[^"]*")$/ do |metric|
  refute_metric_within_usage_limits(metric)
end

Then /^(.*?plan ".+?") should have a usage limit of (\d+) for metric "(.+?)" per "(.+?)"$/ do |plan, value, metric_name, period|
  metric = plan.service.metrics.find_by_system_name!(metric_name)
  assert_not_nil plan.usage_limits.find_by_metric_id_and_period_and_value(metric.id, period, value)
end

Then /^(.*?plan ".+?") should not have hourly usage limit for metric "(.+?)"$/ do |plan, metric_name|
  metric = plan.metrics.find_by_system_name!(metric_name)
  assert_nil plan.usage_limits.find_by_metric_id_and_period(metric.id, 'hour')
end

When /^I (press|follow) "([^"]*)" for the hourly usage limit for (metric "[^"]*")$/ do |action, label, metric|
  usage_limit = metric.usage_limits.find_by_period('hour')
  step %(I #{action} "#{label}" within "##{dom_id(usage_limit)}")
end

When /^I (press|follow) "([^"]*)" for the hourly usage limit for (metric "[^"]*" on application plan "[^"]*")$/ do |action, label, metric|
  usage_limit = metric.usage_limits.find_by_period('hour')
  step %(I #{action} "#{label}" within "##{dom_id(usage_limit)}")
end

When /^I follow "([^"]*)" within usage limits panel for (metric "[^"]*" on application plan "[^"]*")$/ do |label, metric|
  step %(I follow "#{label}" within "##{dom_id(metric)}_slot")
end

def metrics
  find(:css, '#metrics')
end

def plans
  find(:css, '#plans')
end

And(/^limits hits of that plan to (\d+)$/) do |number|
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


Then(/^the plan should (not )?have visible usage limits$/) do |negate|
  @plan.should be
  @plan.usage_limits.visible.count.should be.send(negate ? :== : :>, 0)
end

def visit_edit_plan(plan)
  plan.should be

  step 'I go to the application plans admin page'

  within plans do
    click_on "Edit Application plan '#{plan.name}'"
  end

  page.should have_css 'h1', text: "Application Plan #{plan.name}"
end
