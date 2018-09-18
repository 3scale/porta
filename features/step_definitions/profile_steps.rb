Then /^I should not see an error on company size$/ do
  assert has_no_xpath?("//li[@id='account_profile_attributes_company_size_input']/p[@class='inline-errors']")
end

