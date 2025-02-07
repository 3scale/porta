# frozen_string_literal: true

When "the table is sorted by {string}( again)" do |column|
  find(".pf-c-table__sort", text: column).click
end

When "{} in the {ordinal} row" do |lstep, n|
  within "table tbody tr:nth-child(#{n})" do
    step lstep
  end
end

# Select an action for a given row in a Patternfly table.
#
#   When they select action "Hide" of "Public Plan"
#   And select action "Delete" of "alice@example.org"
#
When "(they )select action {string} of (row ){string}" do |action, row|
  find_inline_actions_of_row(row).find { |node| node.text == action }
                                 .click
end

# TODO: can we use "has_table?" instead of this complex step?
Then /^(?:I |they )?should see (?:the )?following table( with exact columns)?:?$/ do |exact_columns, expected|
  table = extract_table('table', 'tr:not(.search, .table_title)', 'td:not(.select), th:not(.select)')

  # strip html entities and non letter, space or number characters
  #table.first.map!{ |n| n.gsub(/(&#\d+;)|[^a-z\d\s]/i, '').strip }

  head, *body = table
  # merges extra cells not matching head to last column
  # it is useful when there are colspans in headers
  # changes: [['A', 'B'], ['A', 'B', 'C']]
  # into: [['A', 'B'], ['A', 'B C']]

  body.each do |r|
    row = r.shift(head.size - 1)
    r.replace([*row, r.join(' ')])
  end

  retries ||= 1

  options = exact_columns.present? ? { surplus_col: true } : {}
  expected.diff! table, options
rescue Cucumber::MultilineArgument::DataTable::Different, IndexError => error
  if retries > 0
    retries -= 1
    sleep 1
    retry
  end

  if ENV['CI']
    puts error.message
    puts expected.to_s
  end

  raise
end

Then "the table {has} a column {string}" do |present, column|
  assert_equal present, has_css?(".pf-c-table [data-label='#{column}']")
end

# Check some rows and some columns
#
# And the table has the following rows:
#   | Name            | State     |
#   | Jane's Full App | suspended |
#   | Jane's Lite App | live      |
Given "the table has the following row(s)(:)" do |table|
  actual = extract_table('table', 'tr:not(.search)', 'td:not(.select, .pf-c-table__check), th:not(.select, .pf-c-table__check)')
  expected = table.raw

  headers = actual.first
  headers_index = []
  expected.first.each do |target_header|
    headers_index << headers.find_index(target_header)
  end

  actual_filtered = actual.map do |row|
    row.select.with_index { |column, i| headers_index.include?(i) }
  end

  retries ||= 3
  assert(expected.all? { |row| actual_filtered.include?(row) })
rescue Minitest::Assertion
  retries -= 1
  if retries > 0
    sleep 1
    retry
  end

  raise
end

# Check all rows but not all columns
#
# And the table should contain the following:
#   | Name            | State     |
#   | Jane's Full App | suspended |
#   | Jane's Lite App | live      |
Then "the table should contain the following(:)" do |table|
  actual = extract_table('table', 'thead tr:not(.search), tbody tr', 'td:not(.select, .pf-c-table__check), th:not(.select, .pf-c-table__check)')
  expected = table.raw

  headers = actual.first
  headers_index = []
  expected.first.each do |target_header|
    headers_index << headers.find_index(target_header)
  end

  actual_filtered = actual.map do |row|
    row.select.with_index { |column, i| headers_index.include?(i) }
  end

  assert_same_elements expected, actual_filtered
end

Then "the table should be sorted by {string}" do |column|
  assert_selector(:css, '.pf-c-table .pf-c-table__sort.pf-m-selected', text: column)
end

Then "the table should have {int} row(s)" do |count|
  assert_equal count, find_all('table tbody tr').length
end

Then "the actions of row {string} are:" do |row, table|
  actions = find_inline_actions_of_row(row)

  assert_same_elements table.raw.flatten, actions.map(&:text)
end

# The table where the first column contains headers, and the second one contains values
Then "the inverted table has the following row(s)(:)" do |table|
  actual = extract_table('table', 'tr:not(.search)', 'td:not(.select, .pf-c-table__check), th:not(.select, .pf-c-table__check)')
  expected = table.raw.first
  assert_includes actual, expected
end

Then "the table {should} have a column {string}" do |should, column|
  assert_equal should, has_css?('table thead th', text: column, wait: 0)
end
