# frozen_string_literal: true

Given "the search server is offline" do
  ThinkingSphinx::Test.stop
end

When "the table is filtered with:" do |table|
  table.hashes.each do |search|
    within '.pf-c-toolbar .pf-m-filter-group' do
      pf4_select(search[:value], from: search[:filter])
    end
  end
end

# DEPRECATED: remove and use "the table is filtered with:"
When "I/they search for:" do |table|
  ActiveSupport::Deprecation.warn 'remove and use "the table is filtered with:"'
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
  assert_equal query, find('.pf-m-search-filter .pf-c-text-input-group__text-input')[:value]
end

When "they search and there are no results" do
  perform_toolbar_search('FOO BAR BANANA')
end

Then "they should see an empty state" do
  within('.pf-c-empty-state') do
    assert_selector(:css, '.pf-c-title')
    assert_selector(:css, '.pf-c-empty-state__body')
  end
end

Then "they should see an empty search state" do
  within('tbody .pf-c-empty-state') do
    assert_selector(:css, '.pf-c-title', text: 'No results found')
    assert_selector(:css, '.pf-c-empty-state__body')
    assert_selector(:css, '.pf-c-empty-state__primary', text: 'Clear all filters')
  end
end

And "they should be able to reset the search" do
  within('.pf-c-empty-state') do
    click_link('Clear all filters')
  end

  assert_not has_css?('.pf-c-empty-state')
  assert find_all('tbody tr').size > 1
end

When "they search {string} using the toolbar" do |text|
  perform_toolbar_search(text)
end

And "can able to reset the toolbar filter {string}" do |filter|
  within '.pf-m-filter-group' do
    find_pf_select(filter.capitalize)
      .find('.pf-c-select__toggle-clear')
      .click
  end
end

def perform_toolbar_search(text)
  within '.pf-m-search-filter' do
    find('.pf-c-text-input-group__text-input').set(text)
    find('button[aria-label="Search"]').click
  end
end
