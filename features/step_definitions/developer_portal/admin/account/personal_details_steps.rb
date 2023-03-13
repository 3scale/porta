# frozen_string_literal: true

Given "the buyer wants to edit their personal details" do
  visit admin_account_personal_details_path
end

When "the buyer edits their personal details" do
  @new_password = 'ultrasecret'
  fill_in('user[username]', with: 'Alfred')
  fill_in('user[email]', with: 'alfred@batcave.com')
  fill_in('user[password]', with: @new_password)
  fill_in('user[password_confirmation]', with: @new_password)
end

When "the buyer with SSO edits their personal details" do
  fill_in('user[username]', with: 'Alfred')
  fill_in('user[email]', with: 'alfred@batcave.com')
end

And "the buyer writes a wrong current password" do
  fill_in('user[current_password]', with: 'megasecret')
end

And "the buyer writes a correct current password" do
  fill_in('user[current_password]', with: 'supersecret')
end

And "clicks on update personal details" do
  click_on 'Update Personal Details'
end

Then "they should not be able to edit their personal details" do
  click_on 'Update Personal Details'
  assert has_css?('.help-block', text: 'Current password is incorrect')
  assert_flash 'CURRENT PASSWORD IS INCORRECT.'
  assert 'Current password is incorrect.'
  assert_current_path admin_account_personal_details_path
end

Then "they should be able to edit their personal details" do
  click_on 'Update Personal Details'
  assert_flash 'USER WAS SUCCESFULLY UPDATED.'
  assert_current_path admin_account_personal_details_path
  assert_equal find('#user_username').value, current_user.username
  assert_equal find('#user_email').value, current_user.email
  assert_equal BCrypt::Password.new(current_user.password_digest), @new_password
end

When "they don't provide any personal details" do
  fill_in('user[username]', with: '')
  fill_in('user[email]', with: '')
end

Then "with SSO they should be able to edit their personal details" do
  click_on 'Update Personal Details'
  assert_flash 'USER WAS SUCCESFULLY UPDATED.'
  assert_current_path admin_account_personal_details_path
  assert_equal find('#user_username').value, current_user.username
  assert_equal find('#user_email').value, current_user.email
end

Then "they should see email errors" do
  click_on 'Update Personal Details'
  assert has_css?('#user_email.error')
  assert has_css?('.inline-errors', text: 'is too short (minimum is 6 characters) and should look like an email address')
end

Given "a buyer logged in with SSO" do
  step %(
    When I authenticate by Oauth2
  )
end

Then "the buyer shouldn't see any reference to password" do
  assert has_no_css?("#user_current_password")
  assert has_no_css?("#user_password")
  assert has_no_css?("#user_password_confirmation")
end

When "the buyer edits their custom personal details" do
  fill_in('user[first_name]', with: 'Alfred')
  fill_in('user[user_extra_required]', with: 'Butler')
end

Then "they should be able to edit their custom personal details" do
  click_on 'Update Personal Details'
  assert_flash 'USER WAS SUCCESFULLY UPDATED.'
  assert_current_path admin_account_personal_details_path
  assert_equal find('#user_first_name').value, current_user.first_name
  assert_equal find('#user_user_extra_required').value, current_user.extra_fields["user_extra_required"]
end
