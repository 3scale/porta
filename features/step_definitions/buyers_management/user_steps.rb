# frozen_string_literal: true

Then "I should see {user}" do |user|
  within "#users ##{dom_id(user)}" do
    step %(I should see "#{user.username}")
  end
end

#TODO: move buyer users steps outta here?
Then "I should see buyer {user}" do |user|
  within "#buyer_users ##{dom_id(user)}" do
    step %(I should see "#{user.username}")
  end
end

Then /^I should not see buyer user "([^"]*)"$/ do |user_name|
  within "#buyer_users" do
    step %(I should not see "#{user_name}")
  end
end

Then "I should see button to delete {user}" do |user|
  user_rm_form = "//form[@action='#{provider_admin_account_user_path(user)}'][@method='post']//input[@name='_method'][@value='delete'][@type='hidden']"
  assert has_xpath?(user_rm_form, visible: :hidden)
end

Then "I should not see button to delete {user}" do |user|
  user_rm_form = "//form[@action='#{provider_admin_account_user_path(user)}'][@method='post']//input[@name='_method'][@value='delete']"
  assert has_no_xpath?(user_rm_form)
end

Then "I should see button to suspend buyer {user}" do |user|
  assert_selector(:css, %(form[action = "#{suspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then "I should not see button to suspend buyer {user}" do |user|
  assert has_no_css?(%(form[action = "#{suspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then "I should see button to unsuspend buyer {user}" do |user|
  assert_selector(:css, %(form[action = "#{unsuspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

Then "I should not see button to unsuspend buyer {user}" do |user|
  assert has_no_css?(%(form[action = "#{unsuspend_admin_buyers_account_user_path(user.account, user)}"][method = "post"]))
end

When /^I navigate to the edit page of user "([^\"]*)" of buyer "([^\"]*)"$/ do |user, buyer|
  step 'I navigate to the accounts page'
  step %(I follow "#{buyer}")
  number_of_users = @provider.buyers.where(org_name: buyer).first!.users.count
  step %(I follow "#{number_of_users} Users")
  find('tr', text: user).click_link('Edit')
end

Then "the user is a(n) {word}" do |role|
  assert find('tr th', text: 'Role').has_sibling?('td', text: role)
end
