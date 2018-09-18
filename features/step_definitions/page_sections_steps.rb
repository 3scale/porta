Then /^I should see the links in the ([^:]+):$/ do |section, table|
  table.hashes.each do |hash|
    step %(I should see the link #{hash['link']} in the #{section})
  end
end

Then /^I should see the "links" in the ([^:]+):$/ do |section, table|
  table.hashes.each do |hash|
    step %(I should see the link "#{hash['link']}" in the #{section})
  end
end


# This does not work with the solution above, because of a limitation/feature in capybara.
Then /^I should see "([^"]*)" in a header$/ do |content|
  assert_selector 'h1,h2,h3,h4,h5,h6', text: content
end

Then /^I should not see "([^"]*)" in a header$/ do |content|
  assert_no_selector 'h1,h2,h3,h4,h5,h6', text: content
end

Then /^I should not see the user widget$/ do
  assert_no_selector :xpath, "//div[@id='user_widget']"
end
