Then /^I should see the hits metric for cinstance belonging to "([^"]*)"$/ do |buyer_name|
  buyer_account = Account.find_by_org_name!(buyer_name)
  metric = buyer_account.bought_cinstance.metrics.hits

  selector = XPath.generate { |x| x.descendant(:div)[x.attr(:'data-metric') == metric.name ] }
  should have_xpath(selector)
end


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
      assert_text row['Buyer']
    end
  end
end

Then(/^I should see that application stats$/) do
  page.should have_content "Usage statistics for #{@application.name}"
end


And(/^I select (.+?) from the datepicker$/) do |date|
  page.evaluate_script <<-JS
    (function(){
      var date = #{date.to_s.to_json}
      $('#current-date').data('date', date)
      Stats.SearchOptions.since = date
      $('#submit-stats-search').click()
    }());
  JS
end

Then(/^the stats should load$/) do
  page.should_not have_selector('.loading', visible: true)
end
