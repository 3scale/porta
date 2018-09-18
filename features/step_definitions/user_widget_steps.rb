Then /^I should see the link to the dashboard$/ do
  assert has_css? 'a', :text => "Dashboard"
end

Then /^I should see the link to the admin area$/ do
  assert has_css? 'a', :text => "Admin"
end

