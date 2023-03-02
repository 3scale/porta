Given /^the default set of permissions is created$/ do
end

Then /^finance should not show in the permissions list$/ do
  assert has_no_xpath?("//label", :text => "Permission to be able to manage Finance")
end
