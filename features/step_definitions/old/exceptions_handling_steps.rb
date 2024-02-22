# frozen_string_literal: true

#OPTIMIZE: parameterize like the other one?
When /^I request the url of (the .* page) then I should see an exception$/ do |page|
  assert_path_returns_error path_to(page)
end

Then "they should see an error when going to {page}" do |page|
  assert_path_returns_error page
end

Then "they should see an error when going to the following pages:" do |table|
  table.raw.flatten.each do |page|
    assert_path_returns_error path_to(page)
  end
end

When(/^I request the url of (the .* page) then I should see (\d+)$/) do |page, status|
  assert_path_returns_error(path_to(page), status_code: status)
end
