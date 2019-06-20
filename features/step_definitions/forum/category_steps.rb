Given /^(the forum of "[^"]*") has category "([^"]*)"$/ do |forum, name|
  forum.categories.create!(:name => name)
end

Given /^(the forum of "[^"]*") has categories "([^"]*)" and "([^"]*)"$/ do |forum, one, two|
  forum.categories.create!(:name => one)
  forum.categories.create!(:name => two)
end

Given /^(the forum of "[^"]*") has no categories$/ do |forum|
  forum.categories.destroy_all
end

Then /^(the forum of "[^"]*") should have category "([^"]*)"$/ do |forum, name|
  assert_not_nil forum.categories.find_by_name(name)
end

Then /^(the forum of "[^"]*") should not have category "([^"]*)"$/ do |forum, name|
  assert_nil forum.categories.find_by_name(name)
end

Then /^I should see category "([^"]*)" in the list$/ do |name|
  assert has_css?('table#categories td a', :text => name)
end

Then /^I should not see category "([^"]*)" in the list$/ do |name|
  assert has_no_css?('table#categories td a', :text => name)
end

When /^I (follow|press) "([^"]*)" for category "([^"]*)"$/ do |action, label, name|
  element = action == 'follow' ? 'a' : 'button'

  xpath_widget = "//table[@id='categories']/descendant::*[text()[contains(.,'#{name}')]]/ancestor::tr/descendant::#{element}[text()[contains(.,'#{label}')]]"
  find(:xpath, xpath_widget).click
end

When /^I should not see (link|button) "([^"]*)" for category "([^"]*)"$/ do |widget, label, name|
  element = widget == 'link' ? 'a' : 'button'

  assert has_no_css?(%(#categories td:contains("#{name}") ~ td #{element}:contains("#{label}")))
end
