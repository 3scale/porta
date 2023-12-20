# frozen_string_literal: true

When /^(.*) in the request password reset form$/ do |action|
  within "form[action='#{provider_password_path}']" do
    step action
  end
end

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by(email: email)
end

Then "the password of {user} should not be {string}" do |user, password|
  assert !user.authenticated?(password)
end

When /^I follow the link found in the password reset email send to "([^"]*)"$/ do |email|
  visit_url_in_email(email, /Lost password recovery/)

end

When /^(?:|I )follow the link found in the provider password reset email send to "([^"]*)"$/ do |email|
  visit_url_in_email(email, /Password Recovery/)
end

def visit_url_in_email(email, subject)
  User.find_by!(email: email)

  message = open_email(email, :with_subject => subject)

  url = message.body.to_s.scan(/http.*/).first
  assert_not_nil url, 'URL not found in the email'

  visit url
end

Then 'I should see the password confirmation error' do
  %q(I should see error "doesn't match Password" for field "Password confirmation")
end

When "the buyer wants to reset their password" do
  step 'the current domain is foo.3scale.localhost'
  step 'I go to the login page'
  step 'I follow "Forgot password?"'
end

Then "the buyer fills in the form" do
  fill_in("Email", with: "zed@3scale.localhost")
  click_on "Send instructions"
end

Then "it should not be possible to reset their password" do
  assert_not has_link?('Forgot password?', visible: :all)
  visit path_to('the provider reset password page')
  assert_content 'Not Found'
end

Given "{user} has requested a new password" do |user|
  user.generate_lost_password_token!
end

And "{user} is now able to sign in with password {string}" do |user, password|
  fill_in('Username', with: user.username)
  fill_in('Password', with: password)
  click_button('Sign in')

  assert_content 'Signed in successfully'
  find(:css, '[aria-label="Session toggle"]').click
  assert_content "Signed in to #{@provider.org_name} as #{user.username}"
end
