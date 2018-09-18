Given /^the Sphinx indexes are updated$/ do
  ::ThinkingSphinx::Test.index
  sleep(1.0) # Wait for Sphinx to catch up
end

Given /^Sphinx is offline$/ do
  ::ThinkingSphinx::Test.stop
end

When /^I search for "([^"]*)"$/ do |query|
  step %(I fill in "query" with "#{query}")
  within(".operations") do
    step %(I press "Search")
  end
end


When /^I search for:$/ do |table|

  within ".search" do
    table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }

    search = table.hashes.first

    fill_in('search_query', :with => search[:group_org]) if search[:group_org]
    fill_in('search_name', :with => search[:name]) if search[:name]
    fill_in('search_account_query', :with => search[:account]) if search[:account]
    select(search[:plan], :from => 'search_plan_id') if search[:plan]
    select(search[:paid], :from => 'search_plan_type') if search[:paid]
    select(search[:state], :from => 'search_state') if search[:state]

    click_button("Search")
  end

end

Then /^I should see highlighted "([^"]*)" in "([^"]*)"$/ do |text, section|
  case section
  when "definition"
    page.should have_css('dd span.match', text: text)
  when "term"
    page.should have_css('dt a span.match', text: text)
  end
end
