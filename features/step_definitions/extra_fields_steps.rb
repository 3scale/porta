# frozen_string_literal: true

Then /^I should see error "([^"]*)" for extra field "([^"]*)"$/ do |error, field|
  #TODO: the text selector is nasty
  assert has_xpath?("//*[contains(@class,'has-error')]/label[contains(text(),'#{field.first}')]")
end

Then /^I should not see errors for extra field "([^\"]*)"$/ do |field|
  #TODO: the text selector is nasty
  assert has_no_xpath?("//*[contains(@class,'has-error')]/label[contains(text(),'#{field.first}')]")
end
