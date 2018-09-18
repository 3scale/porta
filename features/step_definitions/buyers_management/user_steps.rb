Then /^I should see (user "[^"]*")$/ do |user|
  step %(I should see "#{user.username}" within "#users ##{dom_id(user)}")
end

#TODO: move buyer users steps outta here?
Then /^I should see buyer (user "[^"]*")$/ do |user|
  step %(I should see "#{user.username}" within "#buyer_users ##{dom_id(user)}")
end

Then /^I should not see buyer user "([^"]*)"$/ do |user_name|
  step %(I should not see "#{user_name}" within "#buyer_users")
end

Then /^I should see button to delete buyer (user "[^"]*")$/ do |user|
  within %(form[action = "#{admin_buyers_account_user_path(user.account, user)}"][method = "post"]) do
    assert has_css?('input[name=_method][value=delete]')
    assert has_css?('button')
  end
end

Then /^I should not see button to delete buyer (user "[^"]*")$/ do |user|
  user_rm_form = "//form[@action='#{admin_buyers_account_user_path(user.account, user)}'][@method='post']//input[@name='_method'][@value='delete']"
  assert has_no_xpath?(user_rm_form)
end

Then /^I should see button to delete (user "[^"]*")$/ do |user|
  user_rm_form = "//form[@action='#{provider_admin_account_user_path(user)}'][@method='post']//input[@name='_method'][@value='delete']"
  assert has_xpath?(user_rm_form)
end

Then /^I should not see button to delete (user "[^"]*")$/ do |user|
  user_rm_form = "//form[@action='#{provider_admin_account_user_path(user)}'][@method='post']//input[@name='_method'][@value='delete']"
  assert has_no_xpath?(user_rm_form)
end

Then /^I should see button to suspend buyer (user "[^"]*")$/ do |user|
  assert has_css?(%(form[action = "#{suspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then /^I should not see button to suspend buyer (user "[^"]*")$/ do |user|
  assert has_no_css?(%(form[action = "#{suspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then /^I should see button to unsuspend buyer (user "[^"]*")$/ do |user|
  assert has_css?(%(form[action = "#{unsuspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then /^I should not see button to unsuspend buyer (user "[^"]*")$/ do |user|
  assert has_no_css?(%(form[action = "#{unsuspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end



When /^I navigate to the edit page of user "([^\"]*)" of buyer "([^\"]*)"$/ do |user, buyer|
  step %(I follow "Developers")
  step %(I follow "#{buyer}")
  step %(I follow "Users")
  step %(I follow "Edit" within the "#{user}" row)
end

When /^I change the user role on the account to "([^\"]*)"$/ do |new_role|
  choose new_role
end

Then /^I should see the users listed$/ do
  response.should have_tag('table#users')
end

Then /^I should see the user "([^\"]*)" user edit page$/ do |username|
  step %{I should see "Edit user #{username} of partner account #{@buyer.org_name}"}
end

Then /^I should see the list of buyer users without user "([^\"]*)"$/ do |username|
  response.should_not have_tag('table#users') do
    with_tag 'a', username
  end
end

Then /^I should see the user new status as "([^\"]*)"$/ do |state|
  @old_status = @user.state
  step %{I should see "User was successfully marked as #{@user.reload.state}."}
  response.should have_tag("td#state-user-#{@user.id}", state)
end

Then /^I should see the user old status$/ do
  response.should have_tag("td#state-user-#{@user.id}", @old_status)
end

Then /^I should see the (user "[^\"]*") new role is "([^\"]*)"$/ do |user, role|
  user.role.should == role.to_sym
  response.should have_tag("td#user-#{user.id}-role", role)
end

When /^I do a HTTP request to impersonate (user "[^"]*")$/ do |user|
  page.driver.browser.process :post, impersonate_admin_buyers_account_user_path(user.account, user)
end
