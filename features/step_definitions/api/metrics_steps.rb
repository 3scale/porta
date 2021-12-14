# frozen_string_literal: true

Given('the following metrics:') do |table|
  table.raw.flatten.each do |name|
    FactoryBot.create(:metric, service: @provider.default_service, system_name: name, friendly_name: name)
  end
end

Given('the following methods:') do |table|
  table.raw.flatten.each do |name|
    FactoryBot.create(:method, owner: @provider.default_service, friendly_name: name)
  end
end

Then('I should see the following methods:') do |table|
  find_rows table.raw.flatten, within: methods_table
end

Then('I should see the following metrics:') do |table|
  find_rows table.raw.flatten, within: metrics_table
end

Given('{method} {is} mapped') do |method, mapped|
  map_or_unmap_metric(method, mapped)
end

Given('{metric} {is} mapped') do |metric, mapped|
  map_or_unmap_metric(metric, mapped)
end

def map_or_unmap_metric(metric, mapped)
  return if metric.decorate.mapped? == mapped

  if mapped
    FactoryBot.create(:proxy_rule, proxy: metric.owner.proxy, metric: metric)
  else
    metric.proxy_rules.delete_all
  end
end

Then('I {should} be able to add a mapping rule to {string}') do |not_mapped, name|
  td = find('table tbody tr', text: name).find('[data-label="Mapped"]')
  assert_equal not_mapped ? 'Add a mapping rule' : '', td.text
end

def find_rows(metrics, within:)
  with_scope within do
    metrics.each do |name|
      find('tbody td', text: name)
    end
  end
end

def methods_table
  find 'table[aria-label="Methods table"]'
end

def metrics_table
  find 'table[aria-label="Metrics table"]'
end
