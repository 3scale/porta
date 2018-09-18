Then /^fields should be required:$/ do |table|
  table.rows.each do |row|
    field = row.first
    assert page.has_xpath?("//label[normalize-space(text())='#{field}']/abbr[@title='required']"),
           "Field #{field.first} is not required"
  end
end

Then /^I should see error in fields:$/ do |table|
  table.rows.each do |field|
    assert has_xpath?("//*[contains(@class,'has-error')]/label[contains(text(),'#{field.first}')]"),
           "Field '#{field.first}' with error not found"
  end
end

Then /^I should not see error in fields:$/ do |table|
  table.rows.each do |field|
    assert has_no_xpath?("//*[contains(@class,'has-error')]/label[contains(text(),'#{field.first}')]"),
          "Field '#{field.first}' has error and shouldn't"
  end
end

Then /^I should see "([^"]*)" in the "([^"]*)" field$/ do |text, field|
   has_xpath?("//tr//th[text() = '#{field}']/following-sibling::td[normalize-space(text()) = '#{text}']")
end

Then /^I should see "([^"]*)" in the "([^"]*)" field in the list$/ do |text, field|
   has_xpath?("//dl//dt[text() = '#{field}']/following-sibling::dd[normalize-space(text()) = '#{text}']")
end
