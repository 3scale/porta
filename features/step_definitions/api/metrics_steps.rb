# frozen_string_literal: true

Given "{product} has a {word} {string}" do |product, method_or_metric, name|
  FactoryBot.create(method_or_metric.to_sym, owner: product, friendly_name: name)
end

Given "{product} has the following {word}:" do |product, method_or_metric, table|
  raise ArgumentError, "#{method_or_metric} is invalid" unless %w[method methods metric metrics].include?(method_or_metric)

  transform_table(table).hashes.each do |opts|
    FactoryBot.create(method_or_metric.singularize.to_sym, owner: product, **opts)
  end
end

# TODO: update
Given "a backend api with the following {word}:" do |method_or_metric, table|
  backend = @provider.default_service.backend_api
  raise ArgumentError, "#{method_or_metric} is invalid" unless %w[method methods metric metrics].include?(method_or_metric)

  table.raw.flatten.each do |name|
    FactoryBot.create(method_or_metric.singularize.to_sym, owner: backend, friendly_name: name)
  end
end

Given('method/metric {string} {is} mapped') do |name, mapped|
  metric = Metric.find_by!(friendly_name: name)
  unless metric.decorate.mapped? == mapped
    owner = metric.owner

    if mapped
      FactoryBot.create(:proxy_rule, proxy: owner.proxy, metric: metric) if owner.instance_of? Service
      FactoryBot.create(:proxy_rule, owner: owner, metric: metric) if owner.instance_of? BackendApi
    else
      metric.proxy_rules.delete_all
    end
  end
end

Then "(I )should be able to add a mapping rule to {string}" do |name|
  assert_equal 'Add a mapping rule', find_mapped_cell_in_table(name).text
end

Then "(I )should see {string} (already )mapped" do |name|
  assert_equal '', find_mapped_cell_in_table(name).text
end

def find_mapped_cell_in_table(text)
  find('.pf-c-table tbody tr', text: text).find('[data-label="Mapped"]')
end

Given "a metric {string} with friendly name {string} of {provider}" do |name, friendly_name, provider|
  FactoryBot.create(:metric, owner: provider.default_service, system_name: name, friendly_name: friendly_name)
end

Given "{plan} has defined the following usage limits:" do |plan, table|
  transform_usage_limits_table(table, plan)
  table.hashes.each do |row|
    FactoryBot.create(:usage_limit, plan: plan,
                                    metric: row[:metric],
                                    period: row[:period],
                                    value: row[:max_value])
  end
end

Given "{plan} has defined all usage limits for {string}" do |plan, metric|
  metric = plan.issuer.metrics.find_by!(friendly_name: metric)

  UsageLimit::PERIODS.each do |period|
    FactoryBot.create(:usage_limit, plan: plan,
                                    period: period,
                                    value: 1,
                                    metric: metric)
  end
end

When "I hide the {metric}" do |metric|
  find(:xpath, "//span[@id='metric_#{metric.id}_visible']//a").click
end

When "I change the {metric} to show with icons and text" do |metric|
  find(:xpath, "//span[@id='metric_#{metric.id}_icons']//a").click
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

Then "(I ){should} see metric {string}" do |should, name|
  assert_equal should, has_css?('.pf-c-table[aria-label="Metrics table"] td[data-label="Metric"]', text: name, wait: 0)
end

Then "(I ){should} see method {string}" do |should, name|
  assert_equal should, has_css?('.pf-c-table[aria-label="Methods table"] td[data-label="Method"]', text: name, wait: 0)
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

And "{metric} is used in the latest gateway configuration" do |metric|
  Proxy.any_instance.expects(:metric_in_latest_configs?).with(metric.id).returns(true).at_least_once
end

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
