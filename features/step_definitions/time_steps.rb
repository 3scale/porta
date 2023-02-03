# frozen_string_literal: true

# This is a hack used only for debugging.
When 'I wait a moment' do
  wait_for_requests
end

When /^I wait (?:for )?(\d+) seconds?$/ do |seconds|
  sleep(seconds.to_i)
end

Given "it's the beginning of the month" do
  time_machine(Time.zone.now.at_beginning_of_month)
end
