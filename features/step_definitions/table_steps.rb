Then /^I should see following table:$/ do |expected|
  table = extract_table('table.data', 'tr:not(.search)', 'td:not(.select), th:not(.select)')

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
  rescue Cucumber::Ast::Table::Different, IndexError => error
    if ENV['CI']
      puts error.message
      puts expected.to_s
    end

    raise
  end
end

