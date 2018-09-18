
When /^I do not agree to the terms and conditions$/ do
  uncheck "I agree to the terms and conditions to sign up"
end

Then /^I should see the error that the terms and conditions should be accepted$/ do
  response.should have_text /must be accepted/
end
