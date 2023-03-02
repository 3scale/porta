Then(/^the master should have plenty of notifications$/) do
  notifications = Notification.where(user_id: Account.master.users)

  assert_operator notifications.count, :>=, 2
end
