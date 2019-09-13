When /^I customize the account plan$/ do
  click_link "Convert to a Custom Plan"
  wait_for_requests
end

When /^I decustomize the account plan$/ do
  click_button "Remove customization"
end

Then /^I should see the account plan is customized$/ do
  assert has_xpath?("//h3", :text => "Custom Account Plan")
end

Then /^I should not see the account plan is customized$/ do
  assert has_no_xpath?("//h3", :text => "Custom Account Plan")
end
