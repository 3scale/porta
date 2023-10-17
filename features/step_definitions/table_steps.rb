# frozen_string_literal: true

Then "I/they should see (the )following table:" do |expected|
  ThreeScale::Deprecation.warn "Detected old table. Move to PF4 and use step 'I should see the following table:'"
  table = extract_table('table.pf-c-table', 'tr:not(.search)', 'td:not(.select), th:not(.select)')

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

  begin
    expected.diff! table
  rescue Cucumber::MultilineArgument::DataTable::Different, IndexError => error
    if ENV['CI']
      puts error.message
      puts expected.to_s
    end

    raise
  end
end

Then "I should see column {string} in ascending order" do |column|
  header = find('th.pf-m-selected', text: column)
  # HACK: icons will be invisible unless @javascript is enabled, they are imported in packs/provider.scss
  assert header.has_css?('i.fa-long-arrow-alt-up', visible: false)
end

Then "the table {has} a column {string}" do |present, column|
  assert_equal present, has_css?(".pf-c-table [data-label='#{column}']")
end

And "the table should contain the following:" do |table|
  expected = extract_table('table', 'tr:not(.search)', 'td:not(.select), th:not(.select)')
  actual = table.raw

  headers = expected.first
  headers_index = []
  actual.first.each do |target_header|
    headers_index << headers.find_index(target_header)
  end

  filtered = expected.map do |row|
    row.select.with_index { |column, i| headers_index.include?(i) }
  end

  assert_same_elements actual, filtered
end

# Then /^I should see the following table:$/ do |expected|
#   table = if has_css?('.pf-c-table')
#             extract_pf4_table
#           else
#             extract_table('table', 'tr', 'th,td')
#           end

#   expected.diff! table
# rescue Cucumber::MultilineArgument::DataTable::Different, IndexError => error
#   if ENV['CI']
#     puts error.message
#     puts expected.to_s
#   end

#   raise
# end
