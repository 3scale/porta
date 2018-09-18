Given /^(buyer "[^\"]*") has extra fields:$/ do |buyer, table|
  buyer.extra_fields = table.hashes.first
  buyer.save!
end

Then /^I should see error "([^"]*)" for extra field "([^"]*)"$/ do |error, field|
  #TODO: the text selector is nasty
  assert has_xpath?("//*[contains(@class,'has-error')]/label[contains(text(),'#{field.first}')]")
end

Then /^I should not see errors for extra field "([^\"]*)"$/ do |field|
  #TODO: the text selector is nasty
  assert has_no_xpath?("//*[contains(@class,'has-error')]/label[contains(text(),'#{field.first}')]")
end
