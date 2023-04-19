# frozen_string_literal: true

Then /^I should be denied the access$/ do
  assert_content 'Access Denied'
end
