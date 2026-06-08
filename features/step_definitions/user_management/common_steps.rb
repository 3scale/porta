# frozen_string_literal: true

# TODO: these steps can be replaced for ".* that belongs to .*"

When /^I choose "([^"]*)" in the user role field$/ do |role|
  with_scope('#user_role_input') do
    choose(role)
  end
end

Then /^I should not see the user role field$/ do
  refute has_xpath?("//fieldset[text()[contains(.,'Role')]]")
end
