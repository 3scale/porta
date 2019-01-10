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

#OPTIMIZE: remove exception from step signature and make it less code aware
When /^I request the url of the '([^\']*)' page then I should see a "([^"]*)" exception$/ do |page, e|
  lambda { visit path_to("the #{page} page") }
    .should raise_error(e.constantize)
end


#TODO: dry this with the other steps
Then /^I request the url of the (page "[^\"]*") an exception should be raised$/ do |page|
  lambda { visit page.path }
    .should raise_error(ActiveRecord::RecordNotFound)
end

When(/^I request the url of the "([^"]*)" page then I should see (\d+)$/) do |page_name, status|
  requests = inspect_requests do
    visit path_to("the #{page_name} page")
  end
  requests.first.status_code.should == status.to_i
end
