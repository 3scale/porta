# frozen_string_literal: true

Given "the buyer wants to edit their personal details" do
  visit admin_account_personal_details_path
end

When "the buyer writes a new name" do
  fill_in('user[username]', with: 'Alfred')
end

When "the buyer writes a new password" do
  fill_in('user[password]', with: 'ultrasecret')
end

And "the buyer confirms their new password" do
  fill_in('user[password_confirmation]', with: 'ultrasecret')
end

And "the buyer writes a new email" do 
  fill_in('user[email]', with: 'alfred@batcave.com')
end

And "the buyer writes their current password" do
  fill_in('user[current_password]', with: 'supersecret')
end

And "clicks on update personal details" do
  click_on 'Update Personal Details'
end

Then "they should see current password is incorrect" do
  assert_flash 'Current password is incorrect.'
  assert_current_path admin_account_personal_details_path
end

Then "they should see their information updated" do
  assert_flash 'User was successfully updated.'
  assert_current_path admin_account_personal_details_path
  assert_equal find('#user_username').value, current_user.username
  assert_equal find('#user_email').value, current_user.email
end

Then "they should have their password updated" do
  assert_flash 'User was successfully updated.'
  assert_current_path admin_account_personal_details_path
end
