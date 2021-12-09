# frozen_string_literal: true

Given('the following metrics:') do |table|
  table.raw.flatten.each do |name|
    FactoryBot.create(:metric, service: service, system_name: name, friendly_name: name)
  end
end

Given('the following methods:') do |table|
  table.raw.flatten.each do |name|
    FactoryBot.create(:method, owner: service, friendly_name: name)
  end
end

Then('I should see the following methods:') do |table|
  find_rows table.raw.flatten, within: methods_table
end

Then('I should see the following metrics:') do |table|
  find_rows table.raw.flatten, within: metrics_table
end

def service
  @service ||= @provider.default_service
end

def find_rows(metrics, within: scope)
  with_scope scope do
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
