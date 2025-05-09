# frozen_string_literal: true

Given "admin of {account} has notification {symbol} {enabled}" do |account, key, enabled|
  account.admins.first.create_notification_preferences(preferences: NotificationPreferences.default_preferences.merge(key => enabled))
end
