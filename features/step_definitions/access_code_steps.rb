Given /^(provider "[^\"]*") has no site access code$/ do |account|
  account.update_attribute(:site_access_code, nil)
end

Given /^(provider "[^\"]*") has site access code "([^\"]*)"$/ do |account, code|
  account.update_attribute(:site_access_code, code)
end


When /^I enter "([^\"]*)" as access code$/ do |code|
  fill_in("Access code", :with => code)
  click_button "Enter"
end

Then /^I should not be in the access code page$/ do
  assert has_no_content?("Access code")
end
