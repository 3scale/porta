# frozen_string_literal: true

When "I follow {string} for user {user}" do |link_text, user|
  step %(I follow "#{link_text}" within "#user_#{user.id}")
end

When "I press {string} for user {user}" do |button_text, user|
  within "#user_#{user.id}" do
    click_button(button_text)
  end
end

When "I choose {string} in the user role field" do |role|
  step %(I choose "#{role}" within "#user_role_input")
end

When "I check {string} in the user permission field" do |permission|
  step %(I check "#{permission}" within "#user_member_permissions_input")
end

Then "I should not see the user role field" do
  refute has_xpath?("//fieldset[text()[contains(.,'Role')]]")
end

Then "I should see {string} for user {user}" do |text, user|
  step %(I should see "#{text}" within "#user_#{user.id}")
end

Then "I should not see {string} for user {user}" do |text, user|
  step %(I should not see "#{text}" within "#user_#{user.id}")
end

When "I request the url of users of {string}" do |provider|
  visit "http://#{provider}/account/users"
end
