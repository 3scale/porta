Then /^I should see the form to export data to csv$/ do
  assert has_css?('h2', :text => "Data Exporter")
  assert has_xpath?('//input[@value="Export CSV"]')
end
