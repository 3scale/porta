# frozen_string_literal: true

Given(/^I add a new mapping rule with method "([^"]*)" pattern "([^"]*)" position "([^"]*)" and metric "([^"]*)"$/) do |method, pattern, position, metric|
  visit "#{URI.parse(current_url).path}/new"
  within('#new-mapping-rule-form form') do
    pf4_select(method, from: 'Verb')
    find('input#proxy_rule_pattern').set pattern
    find('input#proxy_rule_position').set position
    within('#wrapper_metric') do
      find('.pf-c-radio__input').set(true)
      select = find('.pf-c-select')
      within select do
        find('.pf-c-select__toggle').click unless select['class'].include?('pf-m-expanded')
        click_on(metric)
      end
    end
  end
  click_on 'Create mapping rule'
end

MAPPING_RULE_ATTR = %w[http_method pattern position metric].freeze

Then(/^the mapping rules should be in the following order:$/) do |table|
  data = @provider.default_service.proxy.proxy_rules.includes(:metric).ordered
  data.each_with_index do |mapping_rule, index|
    MAPPING_RULE_ATTR.each do |attr|
      actual_value = mapping_rule.public_send(attr)
      actual_value = actual_value.name if attr == 'metric'
      assert_equal table.hashes[index][attr].to_s, actual_value.to_s
    end
  end
end

Given('the service {string} has {int} mapping rules starting with pattern {string}') do |service_name, rules_size, pattern|
  service = @provider.services.find_by(name: service_name)
  hits_metric = service.metrics.first
  proxy_rules = service.proxy.proxy_rules
  rules_size.times do |num|
    proxy_rules.create(http_method: 'GET', pattern: "#{pattern}/num", delta: 1, metric: hits_metric)
  end
end

When('I search mapping rules for pattern {string}') do |query|
  fill_in('search_query', :with => query)
  click_button('Search')
end
