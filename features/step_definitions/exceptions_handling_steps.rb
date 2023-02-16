When /^I want to go to (.+)$/ do |page|
  @want_path = path_to(page)
end

Then /^I should get access denied$/ do
  raise "You must call 'I want to go to ....' before calling this step" unless @want_path
  requests = inspect_requests do
    visit @want_path
  end
  requests.first.status_code.should == 403
end

#OPTIMIZE: parameterize like the other one?
When /^I request the url of the '([^\']*)' page then I should see an exception$/ do |page_to_visit|
  requests = inspect_requests do
    visit path_to("the #{page_to_visit} page")
  end
  requests.first.status_code.should == 403
end

When(/^I request the url of the "([^"]*)" page then I should see (\d+)$/) do |page_name, status|
  requests = inspect_requests do
    visit path_to("the #{page_name} page")
  end
  requests.first.status_code.should == status.to_i
end
