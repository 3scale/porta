# This does not work with the solution above, because of a limitation/feature in capybara.
Then /^I should see "([^"]*)" in a header$/ do |content|
  assert_selector 'h1,h2,h3,h4,h5,h6', text: content
end

Then /^I should not see "([^"]*)" in a header$/ do |content|
  assert_no_selector 'h1,h2,h3,h4,h5,h6', text: content
end
