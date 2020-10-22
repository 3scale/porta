# frozen_string_literal: true

# TODO: check this cucumber expression works
And "all the rolling updates features are {on_off}" do |state|
  if state == 'on'
    TestHelpers::RollingUpdates.rolling_updates_on
  else
    TestHelpers::RollingUpdates.rolling_updates_off
  end
end

When "I have {word} feature {enabled}" do |feature, enabled|
  TestHelpers::RollingUpdates.rolling_update(feature, enabled: enabled)
end

Given "I have rolling updates {string} {enabled}" do |features, enabled|
  Account.any_instance.stubs(:provider_can_use?).returns(true)
  features.split(',').each do |feature|
    Account.any_instance.stubs(:provider_can_use?).with(feature).returns(enabled)
    TestHelpers::RollingUpdates.rolling_update(feature, enabled: enabled)
  end
end
