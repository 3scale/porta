When /^I change the app plan to "([^\"]*)"$/ do |plan|
  select plan, :from => 'Change Plan'
  click_button 'Change'
end

When /^I customize the app plan$/ do
  click_link 'Convert to a Custom Plan'
  # click_link "Back to Application" # this is only in plan scope, in submenu
end

When /^I decustomize the app plan$/ do
  click_button 'Remove customization'
end

Then /^I should not be able to pick a plan$/ do
  should_not have_link('Review/Change')
end
