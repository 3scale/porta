# frozen_string_literal: true

When /^I remember the user key I see$/ do
  @user_key = find('#user-key').text.strip
end

Then /^I should see user key is different from what it was$/ do
  assert_not_equal find('#user-key').text.strip, @user_key
  remove_instance_variable(:@user_key)
end

Then "{application} now has user key {string}" do |application, user_key|
  within(*selector_for('the API Credentials card')) do
    assert has_content?(user_key)
  end

  assert_equal user_key, application.reload.user_key
end

And "{application}'s user key has not changed" do |application|
  old = application.user_key
  assert_equal old, application.reload.user_key
end
