Then /^I should see a chart called "([^\"]*)"$/ do |chart|
  within("##{chart}") do
    assert_selector(:css, "svg")
  end
end

Then /^I should see a list of metrics:$/ do |table|
  table.hashes.each_with_index do |row, index|
    within(".StatsSelector-container") do
      assert_text :all, row['Buyer']
    end
  end
end
