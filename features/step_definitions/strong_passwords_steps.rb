# frozen_string_literal: true

# When RAILS_ENV=test, strong passwords are disabled by default
Given "Strong passwords are disabled" do
  Rails.configuration.three_scale.stubs(:strong_passwords_disabled).returns(true)
end

Then /^I should see the error that the password is too weak$/ do
  assert has_content? "is too short (minimum is 15 characters)"
end
