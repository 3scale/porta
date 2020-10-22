# frozen_string_literal: true

Then "I should have the notification {string} {enabled}" do |name, enabled|
  wait_for_requests
  notification = current_account.mail_dispatch_rules.find_by!(system_operation_id: SystemOperation.find_by!(name: name).id)

  if enabled
    assert notification.dispatch, "#{notification.inspect} should have dispatch"
  else
    refute notification.dispatch, "#{notification.inspect} should not have dispatch"
  end
end

Then "the master should have plenty of notifications" do
  notifications = Notification.where(user_id: Account.master.users)

  assert_operator notifications.count, :>=, 2
end
