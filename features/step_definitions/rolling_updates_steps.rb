# DEPRECATED: do not use it
When(/^RollingUpdates is (enabled|disabled)$/) do |switch|
  Logic::RollingUpdates.stubs(enabled?: switch == 'enabled')
end

include TestHelpers::RollingUpdates

And(/^all the rolling updates features are (on|off)$/) do |state|
  if state
    rolling_updates_on
  else
    rolling_updates_off
  end
end

When(/^I have (\w+) feature (enabled|disabled)$/) do |feature, enabled|
  rolling_update(feature, enabled: enabled == 'enabled')
end
