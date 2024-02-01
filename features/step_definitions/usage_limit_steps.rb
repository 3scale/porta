# frozen_string_literal: true

Given "an usage limit on {plan} for metric {string} with period {word} and value {int}" do |plan, metric_name, period, value|
  metric = plan.metrics.find_by_system_name!(metric_name)
  ul = metric.usage_limits.new :period => period, :value => value
  ul.plan = plan
  ul.save!
end

Then "I should see a usage limit of {int} for {metric_on_application_plan} per {string}" do |value, metric, period|
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
  metric = plan.service.metrics.find_by_system_name!(metric_name)
  assert_not_nil plan.usage_limits.find_by_metric_id_and_period_and_value(metric.id, period, value)
end

Then "{plan} should not have hourly usage limit for metric {string}" do |plan, metric_name|
  metric = plan.metrics.find_by_system_name!(metric_name)
  assert_nil plan.usage_limits.find_by_metric_id_and_period(metric.id, 'hour')
end

When "I {word} {string} for the hourly usage limit for {metric_on_application_plan}" do |action, label, metric|
  usage_limit = metric.usage_limits.find_by_period('hour')
  within "##{dom_id(usage_limit)}" do
    step %(I #{action} "#{label}")
  end
end

def metrics_container
  find(:css, '#metrics')
end

Then "{plan} {should} have visible usage limits" do |plan, should|
  plan.usage_limits.visible.count.should be.send(should ? :> : :==, 0)
end
