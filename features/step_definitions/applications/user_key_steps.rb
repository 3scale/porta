When /^I remember the user key I see$/ do
  @user_key = find('#user-key').text.strip
end

Then /^I should see user key is different from what it was$/ do
  assert_not_equal find('#user-key').text.strip, @user_key
  remove_instance_variable(:@user_key)
end

Then /^(application ".+?") should have user key "(.+?)"$/ do |app, user_key|
  app.user_key.should == user_key
end
