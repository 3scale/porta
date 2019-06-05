When /^I follow "([^\"]*)" for (user "[^\"]*")$/ do |link_text, user|
  step %(I follow "#{link_text}" within "#user_#{user.id}")
end

When /^I press "([^\"]*)" for (user "[^\"]*")$/ do |button_text, user|
  within("#user_#{user.id}") do
    click_button(button_text)
  end
end

When /^I choose "([^"]*)" in the user role field$/ do |role|
  step %(I choose "#{role}" within "#user_role_input")
end

When /^I check "([^"]*)" in the user permission field$/ do |permission|
  step %(I check "#{permission}" within "#user_member_permissions_input")
end

Then /^I should not see the user role field$/ do
  refute has_xpath?("//fieldset[text()[contains(.,'Role')]]")
end

Then /^I should see "([^\"]*)" for (user "[^\"]*")$/ do |text, user|
  step %(I should see "#{text}" within "#user_#{user.id}")
end

Then /^I should not see "([^\"]*)" for (user "[^\"]*")$/ do |text, user|
  step %(I should not see "#{text}" within "#user_#{user.id}")
end

When /^I request the url of users of "([^\"]*)"$/ do |provider|
  visit "http://#{provider}/account/users"
end
