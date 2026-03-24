# frozen_string_literal: true

Given "Strong passwords are disabled" do
  Rails.configuration.three_scale.stubs(:strong_passwords_disabled).returns(true)
end

Then /^I should see the error that the password is too weak$/ do
  assert has_content? "is too short (minimum is 15 characters)"
end
