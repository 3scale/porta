Then /^I should see alert "(.+?)"$/ do |message|
  last_javascript_alert.should == message
end
