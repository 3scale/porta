Given /^Sphinx is offline$/ do
  ::ThinkingSphinx::Test.stop
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

Then "they can filter the table by {string}" do |label|
  all_items = find_items(label)
  input = find('input[aria-label="Search input"]')
  button = find('button[aria-label="Search"]')

  input.set('ab')
  button.click
  assert_selector('.pf-c-popover__body', text: "To search, type at least 3 characters")

  clear_search
  assert_equal all_items, find_items(label)

  input.set(all_items.first)
  button.click
  assert_equal [all_items.first], find_items(label)

  input.set(all_items.last)
  button.click
  assert_includes find_items(label), all_items.last

  input.set('foooo')
  button.click
  assert_empty find_items(label)

  clear_search
  assert_equal all_items, find_items(label)
end

def find_items(label)
  all("td[data-label='#{label}']").map(&:text)
end

def clear_search
  clear_button = find('button[aria-label="Reset"]')
  clear_button.click
end
