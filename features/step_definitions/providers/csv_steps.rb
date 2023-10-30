Then /^I should see the form to export data to csv$/ do
  assert has_css?('h1', :text => "Export")
  assert has_button?('Export CSV')
end
