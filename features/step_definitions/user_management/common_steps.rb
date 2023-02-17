# frozen_string_literal: true

When "I follow {string} for {user}" do |link_text, user|
  step %(I follow "#{link_text}" within "#user_#{user.id}")
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

Then "I should see {string} for {user}" do |text, user|
  step %(I should see "#{text}" within "#user_#{user.id}")
end

Then "I should not see {string} for {user}" do |text, user|
  step %(I should not see "#{text}" within "#user_#{user.id}")
end
