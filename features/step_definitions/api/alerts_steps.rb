# -*- coding: utf-8 -*-

Given /^I have following API alerts:$/ do |table|
  symbolize_headers(table)
  table.hashes.each do |hash|
    cinstance = Transform %{application "#{hash[:application]}"}
    create_alert! cinstance, hash
  end
end

Then /^I should(?: still)? see(?: only)? the following(?: (read|unread))? API alerts?:$/ do |state, expected|
  table = limit_alerts_table state
  expected.diff! table
end

Then /^I should see (\d+) *(?:(read|unread))? API alerts?$/ do |number, state|
  assert_equal number.to_i, limit_alerts_table(state).rows.count
end

Then /^I should not see any(?: (read|unread))? API alerts$/ do |state|
  step %{I should see 0 #{state} API alerts}
end

When /^(.+?) for the (?:(\d) ?(?:st|nd|rd|th)) API alerts?$/ do |action, row|
  within "#limit_alerts tbody tr:nth-child(#{row.to_i})" do
    step action
  end
end
