# frozen_string_literal: true

When "I want to go to {link_to_page}" do |path|
  # TODO: move this into transformer
  @want_path = PathsHelper::PathFinder.new(@provider).path_to(path)
end

Then "I should get access denied" do
  raise "You must call 'I want to go to ....' before calling this step" unless @want_path

  requests = inspect_requests do
    visit @want_path
  end
  assert_equal 403, requests.first.status_code
end

#OPTIMIZE: parameterize like the other one?
When "I request the url of {link_to_page} then I should see an exception" do |page_name|
  # TODO: move this into transformer
  path = PathsHelper::PathFinder.new(@provider).path_to(page_name)
  requests = inspect_requests do
    visit path
  end
  assert_equal 403, requests.first.status_code
end

#OPTIMIZE: remove exception from step signature and make it less code aware
When "I request the url of {link_to_page} then I should see a {string} exception" do |page_name, e|
  # TODO: move this into transformer
  path = PathsHelper::PathFinder.new(@provider).path_to(page_name)
  -> { visit path }
    .should raise_error(e.constantize)
end

#TODO: dry this with the other steps
Then "I request the url of the {page} an exception should be raised" do |page|
  -> { visit page.path }
    .should raise_error(ActiveRecord::RecordNotFound)
end

When "I request the url of {link_to_page} then I should see {int}" do |page_name, status|
  # TODO: move this into transformer
  path = PathsHelper::PathFinder.new(@provider).path_to(page_name)
  requests = inspect_requests do
    visit path
  end
  assert_equal status, requests.first.status_code
end
