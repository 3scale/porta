# frozen_string_literal: true

# TODO: these steps can be replaced for ".* that belongs to .*"

When "I follow {string} for {user}" do |link_text, user|
  find("tr#user_#{user.id} .pf-c-table__action").click_link(link_text)
end

When "I press {string} for {user}" do |button_text, user|
  within("#user_#{user.id}") do
    click_button(button_text)
  end
end

When /^I choose "([^"]*)" in the user role field$/ do |role|
  with_scope('#user_role_input') do
    choose(role)
  end
end

Then /^I should not see the user role field$/ do
  refute has_xpath?("//fieldset[text()[contains(.,'Role')]]")
end
