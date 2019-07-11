# This is a hack used only for debugging.
When 'I wait a moment' do
  wait_for_requests
end

When /^I wait (?:for )?(\d+) seconds?$/ do |seconds|
  sleep(seconds.to_i)
end
