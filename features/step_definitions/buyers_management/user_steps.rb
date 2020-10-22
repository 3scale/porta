# frozen_string_literal: true

Then "I should see user {user}" do |user|
  step %(I should see "#{user.username}" within "#users ##{dom_id(user)}")
end

#TODO: move buyer users steps outta here?
Then "I should see buyer user {user}" do |user|
  step %(I should see "#{user.username}" within "#buyer_users ##{dom_id(user)}")
end

Then "I should not see buyer user {string}" do |user_name|
  step %(I should not see "#{user_name}" within "#buyer_users")
end

Then "I should see button to delete buyer user {user}" do |user|
  within %(form[action = "#{admin_buyers_account_user_path(user.account, user)}"][method = "post"]) do
    assert has_css?('input[name=_method][value=delete]')
    assert has_css?('button')
  end
end

Then "I should not see button to delete buyer user {user}" do |user|
  user_rm_form = "//form[@action='#{admin_buyers_account_user_path(user.account, user)}'][@method='post']//input[@name='_method'][@value='delete'][@type='hidden']"
  assert has_no_xpath?(user_rm_form, visible: true)
end

Then "I should see button to delete user {user}" do |user|
  user_rm_form = "//form[@action='#{provider_admin_account_user_path(user)}'][@method='post']//input[@name='_method'][@value='delete'][@type='hidden']"
  assert has_xpath?(user_rm_form, visible: :hidden)
end

Then "I should not see button to delete user {user}" do |user|
  user_rm_form = "//form[@action='#{provider_admin_account_user_path(user)}'][@method='post']//input[@name='_method'][@value='delete']"
  assert has_no_xpath?(user_rm_form)
end

Then "I should see button to suspend buyer user {user}" do |user|
  assert has_css?(%(form[action = "#{suspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then "I should not see button to suspend buyer user {user}" do |user|
  assert has_no_css?(%(form[action = "#{suspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then "I should see button to unsuspend buyer user {user}" do |user|
  assert has_css?(%(form[action = "#{unsuspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then "I should not see button to unsuspend buyer user {user}" do |user|
  assert has_no_css?(%(form[action = "#{unsuspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

When "I navigate to the edit page of user {string} of buyer {string}" do |user, buyer|
  step 'I navigate to the accounts page'
  step %(I follow "#{buyer}")
  number_of_users = @provider.buyers.where(org_name: buyer).first!.users.count
  step %(I follow "#{number_of_users} Users")
  step %(I follow "Edit" within the "#{user}" row)
end

When "I change the user role on the account to {string}" do |new_role|
  choose new_role
end

Then "I should see the users listed" do
  response.should have_tag('table#users')
end

Then "I should see the {string} user edit page" do |username|
  step %(I should see "Edit user #{username} of partner account #{@buyer.org_name}")
end

Then "I should see the list of buyer users without user {string}" do |username|
  response.should_not have_tag('table#users') do
    with_tag 'a', username
  end
end

Then "I should see the user new status as {string}" do |state|
  @old_status = @user.state
  step %(I should see "User was successfully marked as #{@user.reload.state}.")
  response.should have_tag("td#state-user-#{@user.id}", state)
end

Then "I should see the user old status" do
  response.should have_tag("td#state-user-#{@user.id}", @old_status)
end

Then "I should see the user {user} new role is {string}" do |user, role|
  # FIXME: Operator `==` used in void context.Lint/Void
  user.role.should be role.to_sym
  response.should have_tag("td#user-#{user.id}-role", role)
end
