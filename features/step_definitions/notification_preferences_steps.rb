# frozen_string_literal: true

Given "admin of {account} has notification {symbol} {enabled}" do |account, key, enabled|
  account.admins.first.create_notification_preferences(preferences: NotificationPreferences.default_preferences.merge(key => enabled))
end

Given /^(?:I|they) check only the following notifications:$/ do |table|
  toggle_notification_checkboxes table.raw.flatten.map(&:strip)
end

Then "only the following notifications are checked:" do |table|
  assert_notification_checkboxes table.raw.flatten.map(&:strip)
end

Given "they disable all notifications" do
  toggle_notification_checkboxes []
end

Then "all notifications are unchecked" do
  assert_notification_checkboxes []
end

def assert_notification_checkboxes(enabled_list)
  process_notification_checkboxes(
    enabled_list:,
    enabled_handler: ->(checkbox, label) { assert checkbox.checked?, "Expected '#{label}' checkbox to be checked" },
    disabled_handler: ->(checkbox, label) { assert_not checkbox.checked?, "Expected '#{label}' checkbox to be unchecked" }
  )
end

def toggle_notification_checkboxes(enabled_list)
  process_notification_checkboxes(
    enabled_list:,
    enabled_handler: ->(checkbox, _) { check(checkbox[:id]) },
    disabled_handler: ->(checkbox, _) { uncheck(checkbox[:id]) }
  )
end

def process_notification_checkboxes(enabled_list:, enabled_handler:, disabled_handler:)
  all('input[type="checkbox"]').each do |checkbox|
    label_text = find("label[for='#{checkbox[:id]}']", match: :first).text.strip

    if enabled_list.include?(label_text)
      enabled_handler.call(checkbox, label_text)
    else
      disabled_handler.call(checkbox, label_text)
    end
  end
end
