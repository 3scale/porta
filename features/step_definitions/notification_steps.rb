Then /^I should have the notification "([^"]*)" (enabled|disabled)$/ do |name, status|
  notification = current_account.mail_dispatch_rules.find_by_system_operation_id(SystemOperation.find_by_name(name).id)

  case status
  when 'enabled' then assert notification.dispatch, "#{notification.inspect} should have dispatch"
  when 'disabled' then refute notification.dispatch, "#{notification.inspect} should not have dispatch"
  else raise "#{status} unknown"
  end
end

Then(/^the master should have plenty of notifications$/) do
  notifications = Notification.where(user_id: Account.master.users)

  assert_operator notifications.count, :>=, 2
end
