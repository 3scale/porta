Then /^I fill the form with following:$/ do |table|
  table.hashes.each do |hash|
    hash.each_pair do |key, value|
      fill_in key, :with => value
    end
  end
end

When /^I click on the label "(.*?)"$/ do |label_text|
  page.find('label', :text => label_text).click
end
