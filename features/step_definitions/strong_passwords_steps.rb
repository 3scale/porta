# frozen_string_literal: true

Given "Strong passwords are disabled" do
  Rails.configuration.three_scale.stubs(:strong_passwords_disabled).returns(true)
end

Then /^I should see the error that the password is too weak$/ do
  assert has_content? "is too short (minimum is 15 characters)"
end

When "(I )(they )fill in the sample user credentials" do
  fill_in("Username or Email", with: User::JOHN_DOE_ATTRS[:username])
  fill_in("Password", with: Logic::SampleDeveloperPassword.for(@provider))
end

Then "(they )should see the sample user credentials" do
  sample_user_pass = Logic::SampleDeveloperPassword.for(@provider)
  assert has_content?(User::JOHN_DOE_ATTRS[:username])
  assert has_content?(sample_user_pass)
end
