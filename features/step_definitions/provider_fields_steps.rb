Then /^I should see error in provider side fields:$/ do |table|
  table.rows.each do |field|
    assert has_xpath?(".//*[ label[normalize-space(text()) = '#{field.first}'] ]/..//p[@class='inline-errors']"),
         "Field '#{field.first}' with error not found"
  end
end
