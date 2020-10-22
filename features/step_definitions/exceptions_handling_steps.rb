# frozen_string_literal: true

When "I want to go to {link_to_page}" do |path|
  @want_path = path
end

Then "I should get access denied" do
  raise "You must call 'I want to go to ....' before calling this step" unless @want_path

  requests = inspect_requests do
    visit @want_path
  end
  requests.first.status_code.should be 403
end

#OPTIMIZE: parameterize like the other one?
When "I request the url of the {link_to_page} page then I should see an exception" do |path|
  requests = inspect_requests do
    visit path
  end
  requests.first.status_code.should be 403
end

#OPTIMIZE: remove exception from step signature and make it less code aware
When "I request the url of the {link_to_page} page then I should see a {string} exception" do |path, e|
  -> { visit path }
    .should raise_error(e.constantize)
end

#TODO: dry this with the other steps
Then "I request the url of the {page} an exception should be raised" do |page|
  -> { visit page.path }
    .should raise_error(ActiveRecord::RecordNotFound)
end

When "I request the url of the {link_to_page} page then I should see {int}" do |path, status|
  requests = inspect_requests do
    visit path
  end
  requests.first.status_code.should be status
end
