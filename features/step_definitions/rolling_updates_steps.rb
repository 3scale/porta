# DEPRECATED: do not use it
When(/^RollingUpdates is (enabled|disabled)$/) do |switch|
  Logic::RollingUpdates.stubs(enabled?: switch == 'enabled')
end

And(/^all the rolling updates features are (on|off)$/) do |state|
  if state
    TestHelpers::RollingUpdates.rolling_updates_on
  else
    TestHelpers::RollingUpdates.rolling_updates_off
  end
end

When(/^I have (\w+) feature (enabled|disabled)$/) do |feature, enabled|
  TestHelpers::RollingUpdates.rolling_update(feature, enabled: enabled == 'enabled')
end

Given(/^I have rolling update (\w+) (enabled|disabled)$/) do |feature, enabled|
  Account.any_instance.stubs(:provider_can_use?).returns(true)
  Account.any_instance.stubs(:provider_can_use?).with(feature).returns(false | true)
  TestHelpers::RollingUpdates.rolling_update(feature, enabled: enabled == 'enabled')
end
