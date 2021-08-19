# frozen_string_literal: true

Given "a metric {string} of {provider}" do |metric_name, provider|
  FactoryBot.create(:metric, :service => provider.default_service, :system_name => metric_name, :friendly_name => metric_name)
end

Given "a metric {string} with friendly name {string} of {provider}" do |name, friendly_name, provider|
  FactoryBot.create(:metric, :service => provider.default_service, :system_name => name, :friendly_name => friendly_name)
end

Given "a method {string} of {provider}" do |name, provider|
  FactoryBot.create(:metric, :friendly_name => name, :parent => provider.default_service.metrics.hits)
end

Given "the metrics {with_or_without} usage limits of {plan}:" do |enabled, app_plan, table|
  table.hashes.each do |hash|
    metric = FactoryBot.create(:metric, :service => app_plan.issuer, :friendly_name => hash['metric'])
    if enabled
      ul = app_plan.usage_limits.new(:period => "day", :value => 1)
      ul.metric = metric
      ul.save!
    end
  end
end

Given "the metric {string} {with_or_without} usage limit {int} of {plan}" do |name, enabled, limit, app_plan|
  metric = FactoryBot.create(:metric, :service => app_plan.issuer, :friendly_name => name)
  if enabled
    ul = app_plan.usage_limits.new(:period => "day", :value => limit.to_i)
    ul.metric = metric
    ul.save!
  end
end

Given "the metric {string} with all used periods of {plan}" do |name, app_plan|
  metric = FactoryBot.create(:metric, service: app_plan.issuer, friendly_name: name)

  UsageLimit::PERIODS.each do |period|
    app_plan.usage_limits.create!(period: period, value: 1, metric: metric)
  end
end

When "I hide the {metric}" do |metric|
  find(:xpath, "//span[@id='metric_#{metric.id}_visible']//a").click
end

When "I change the {metric} to show with icons and text" do |metric|
  find(:xpath, "//span[@id='metric_#{metric.id}_icons']//a").click
end

When "I {word} {string} for {method}" do |action, label, metric|
  step %(I #{action} "#{label}" within ".child##{dom_id(metric)}")
end

When "I {word} {string} for {metric}" do |action, label, metric|
  step %(I #{action} "#{label}" within "##{dom_id(metric)}")
end

When "I {word} {string} for {metric_on_application_plan}" do |action, label, metric|
  within "##{dom_id(metric)}" do
    click_on label, visible: true, match: :smart
  end
end

When "I enable/disable the {metric}" do |metric|
  find(:xpath, "//span[@id='metric_#{metric.id}_status']//a").click
end

# FIXME: this step is wrong, the elements are visible by capybara but the class is 'hidden', it shuold be like this:
# assert find(:xpath, "//span[@id='metric_#{metric.id}_visible']").visible? == is_visible
Then "I should see( the) {metric} is {visible_or_hidden}" do |metric, visible|
  wait_for_requests
  assert find(:xpath, "//span[@id='metric_#{metric.id}_visible']")[:class] == visible
end

Then "{provider} should have metric {string}" do |provider, metric_name|
  assert_not_nil provider.default_service.metrics.find_by_system_name(metric_name)
end

Then "{provider} should not have metric {string}" do |provider, metric_name|
  assert_nil provider.default_service.metrics.find_by_system_name(metric_name)
end

Then "{metric} should have the following:" do |metric, table|
  table.raw.each do |row|
    attribute = row[0].downcase.gsub(/\s+/, '_').to_sym
    assert_equal row[1], metric.send(attribute)
  end
end

Then /^I should (not )?see metric "([^"]*)"$/ do |negate, name|
  metrics = XPath.anywhere[XPath.attr(:id).equals('metrics')]
  selector = metrics.descendant(:td)[XPath.text.contains(name)]
  assertion = method(negate ? :assert_no_selector : :assert_selector)
  assertion.call(:xpath, selector)
end

Then "I should not see button {string} for {metric}" do |label, metric|
  within "##{dom_id(metric)}" do
    assert has_no_button?(label)
  end
end

Then "I should not see button {string} for {metric_on_application_plan}" do |label, metric|
  within "##{dom_id(metric)}" do
    assert has_no_button?(label)
  end
end

Then /^I should see method "([^"]*)"$/ do |name|
  page.should have_xpath("//td[text()='#{name}']")
end

Then /^I should not see method "([^"]*)"$/ do |name|
  page.should have_no_xpath("//td[text()='#{name}']")
end

# DEPRECATED: not really integration testing

# DEPRECATED: not really integration testing
Then "{provider} should not have method {string}" do |provider, name|
  assert_nil provider.default_service.metrics.hits.children.find_by_name(name)
end

Then "I should see the {metric} in the plan widget" do |metric|
  assert has_xpath?("//tr[@id='metric_#{metric.id}_limits']/th/span",
                    :text => metric.name)
end

Then "I should see the unlimited {metric} in the plan widget" do |metric|
  assert has_xpath?("//tr[@id='metric_#{metric.id}_unlimited']/th/span",
                    :text => metric.name)
end

Then "I should not see the metric {string} in the plan widget" do |metric|
  assert has_no_xpath?("//table[@class='plan_widget']/tr[@class='usage_limit']/th/span",
                       :text => metric)
end

Then "I should see the {metric} limits show as text" do |metric|
  assert find(:xpath, "//span[@id='metric_#{metric.id}_icons']")[:class] == 'text'
end

Then "I should see the {metric} limits as text in the plan widget" do |metric|
  assert has_no_xpath?("//tr[@id='metric_#{metric.id}_limits']/td/img")
end

Then "I should see the {metric} limits show as icons and text" do |metric|
  wait_for_requests
  assert find(:xpath, "//span[@id='metric_#{metric.id}_icons']")[:class] == 'icon'
end

Then "I should see the {metric} limits as icons and text in the plan widget" do |metric|
  assert has_xpath?("//tr[@id='metric_#{metric.id}_limits']/td/img")
end

Then "I should see the {metric} limits as icons only in the plan widget" do |metric|
  wait_for_requests
  assert find(:xpath, "//tr[@id='metric_#{metric.id}_limits']/td").text.strip.empty?
  assert has_xpath?("//tr[@id='metric_#{metric.id}_limits']/td/img")
end

Then "I should see the {metric} is {enabled_or_disabled}" do |metric, status|
  wait_for_requests
  assert find(:xpath, "//span[@id='metric_#{metric.id}_status']")[:class] == status
end

Then /^I should see the edit limit link$/ do
  assert find('.operations a.edit', text: 'Edit')
end

def new_metric_form
  find(:css, 'form#new_metric')
end

And(/^creates metric for that plan$/) do
  visit_edit_plan(@plan)

  within metrics do
    click_on 'New metric'
  end

  name = SecureRandom.hex(10)

  within new_metric_form do
    fill_in 'Friendly name', with: name
    fill_in 'System name', with: name
    fill_in 'Unit', with: 'thing'

    click_on 'Create Metric'
  end

  page.should have_content 'Metric has been created'
end

Capybara::Node::Element
Capybara::Selenium::Node
And(/^makes hits invisible for that plan$/) do
  visit_edit_plan(@plan)

  visibility_field = find(:xpath, "//*[@id='metric_#{@plan.metrics.first!.id}_visible']")
  assert_equal 'visible', visibility_field[:class]
  visibility_field.click
  block_and_wait_for_requests_complete
  # need to query again the page so it does not use the cached object defined before
  visibility_field = find(:xpath, "//*[@id='metric_#{@plan.metrics.first!.id}_visible']")
  assert_equal 'hidden', visibility_field[:class]
end
