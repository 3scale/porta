When /^I follow my account plan name link$/ do
  click_link current_account.account_plans.first.name
end

Then /^I should see the copy button$/ do
  assert has_content?("Copy")
end

Then /^I should not see the copy button$/ do
  assert has_no_content?("Copy")
end

Then /^I should see only one default plan selector$/ do
  page.should have_css("#default_plan", count: 1)
end

And /^provider has "(.*?)" hidden$/ do |field|
  current_account.settings.toggle!(field)
end

And /^provider has (account|service|end_user) plans hidden from the ui$/ do |type_of_plan|
  current_account.settings.update_attribute("#{type_of_plan}_plans_ui_visible", false)
end

Then(/^there should not be any mention of account plans$/) do
  assert has_no_content?("Account Plans")
  assert has_no_content?("account plans")
  assert has_no_content?("Account plan")
end