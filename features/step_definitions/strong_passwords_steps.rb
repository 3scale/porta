# frozen_string_literal: true

Then /^I should see the error that the password is too weak$/ do
  assert has_content? User::STRONG_PASSWORD_FAIL_MSG
end
