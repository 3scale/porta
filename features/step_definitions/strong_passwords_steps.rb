# frozen_string_literal: true

# When RAILS_ENV=test, strong passwords are disabled by default
Given "Strong passwords are enabled" do
  Rails.configuration.three_scale.stubs(:strong_passwords_disabled).returns(false)
end

Then /^I should see the error that the password is too weak$/ do
  assert has_content? User::STRONG_PASSWORD_FAIL_MSG
end
