# frozen_string_literal: true

When "they edit their personal details" do
  fill_in('user[username]', with: 'Alfred')
  fill_in('user[email]', with: 'alfred@batcave.com')
  # password defined in test/factories/user.rb
  fill_in('user[current_password]', with: 'superSecret1234#') if has_css?('input[name="user[current_password]"]')
end

And "they change their password" do
  @new_password = 'ultraSecret1234#'
  fill_in('user[password]', with: @new_password)
  fill_in('user[password_confirmation]', with: @new_password)
end

Then "they should not be able to edit their personal details" do
  click_on 'Update Personal Details'
  assert_selector(:css, '.help-block', text: 'is incorrect')
  assert_flash 'CURRENT PASSWORD IS INCORRECT'
  assert_current_path admin_account_personal_details_path
end

Then "they should be able to edit their personal details" do
  click_on 'Update Personal Details'
  assert_flash 'USER WAS SUCCESSFULLY UPDATED.'
  assert_current_path admin_account_users_path
  current_user.reload
  assert_selector(:css, 'tr > td:nth-child(2)', text: current_user.username)
  assert_selector(:css, 'tr > td:nth-child(3)', text: current_user.email)
end

And "password has changed" do
  assert_equal BCrypt::Password.new(current_user.password_digest), @new_password
end

When "they don't provide any personal details" do
  fill_in('user[username]', with: '')
  fill_in('user[email]', with: '')
end

Then "they should not be able to edit the email" do
  click_on 'Update Personal Details'
  assert_selector(:css, '#user_email.error')
  assert_selector(:css, '.inline-errors', text: 'is too short (minimum is 6 characters) and should look like an email address')
end

When "the buyer edits their custom personal details" do
  fill_in('user[first_name]', with: 'Alfred')
  fill_in('user[user_extra_required]', with: 'Butler')
  # password defined in test/factories/user.rb
  fill_in('user[current_password]', with: 'superSecret1234#') if has_css?('input[name="user[current_password]"]')
end

Then "they should be able to edit their custom personal details" do
  click_on 'Update Personal Details'
  assert_flash 'USER WAS SUCCESSFULLY UPDATED.'
  assert_current_path admin_account_users_path
  click_on 'Edit user'
  current_user.reload
  assert_equal find('#user_first_name').value, current_user.first_name
  assert_equal find('#user_user_extra_required').value, current_user.extra_fields["user_extra_required"]
end
