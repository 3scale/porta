# frozen_string_literal: true

Given /^Sphinx is offline$/ do
  ::ThinkingSphinx::Test.stop
end

When "I/they search for:" do |table|

  within ".search" do
    parameterize_headers(table)

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

And "the search input should be filled with {string}" do |query|
  assert_equal query, find('input#search_query')[:value]
end

When "they search and there are no results" do
  fill_in('search_query', with: 'FOO BAR BANANA')
  click_button('Search')
end

Then "they should see an empty state" do
  assert_equal 1, find_all('tbody tr').size
  within('.pf-c-empty-state') do
    assert has_css?('.pf-c-title', text: 'No results found')
    assert has_css?('.pf-c-empty-state__body', text: I18n.t('buyers.accounts.empty_search.body'))
  end
end

And "they should be able to reset the search" do
  within('.pf-c-empty-state') do
    click_link('Clear all filters')
  end
end
