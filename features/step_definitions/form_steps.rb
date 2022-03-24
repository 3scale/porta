# frozen_string_literal: true

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

But "will not be able to edit its system name" do
  assert system_name_disabled?
end

def system_name_disabled?
  find('input[name$="[system_name]"]').disabled?
end
