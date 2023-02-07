Then /^I should see a sparkline for "([^\"]*)"$/ do |metric|
  within(".DashboardSection--audience") do
    assert_selector 'div.Dashboard-chart'
  end
end

Then /^I should see a chart called "([^\"]*)"$/ do |chart|
  within("##{chart}") do
    assert has_css?("svg")
  end
end

Then /^I should see a list of metrics:$/ do |table|
  table.hashes.each_with_index do |row, index|
    within(".StatsSelector-container") do
      assert_text :all, row['Buyer']
    end
  end
end

Then(/^I should see that application stats$/) do
  page.should have_content "Traffic statistics for #{@application.name}"
end
