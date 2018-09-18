
Given /^(provider "[^\"]*") has no layouts$/ do |provider|
  assert provider.page_templates.empty?
end


When /^I create a bcms layout$/ do
  visit cms_page_templates_path
  click_link "Add"

  fill_in "Name", :with => "name"

  find(:xpath, ".//input[@id='page_template_submit']").click
end

When /^I update a layout$/ do
  visit cms_page_templates_path
  find(:xpath, ".//tr[@id='page_template_#{current_account.page_templates.first.id}']").click
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in "Name", :with => "new layout"
  find(:xpath, ".//input[@id='page_template_submit']").click

  sleep 0.5
end

When /^I delete a layout$/ do
  visit cms_page_templates_path
  find(:xpath, ".//tr[@id='page_template_#{current_account.page_templates.first.id}']").click
  find(:xpath, ".//a[@id='delete_button']").click

  sleep(0.5)
end


Then /^I should see my layouts$/ do
  current_account.page_templates.each do |layout|
    assert has_xpath?(".//tr[@id='page_template_#{layout.id}']")
  end
end

Then /^I should see my layout$/ do
  layout = current_account.page_templates.first
  assert has_xpath?(".//tr[@id='page_template_#{layout.id}']")
end

Then /^I should see the layout changed$/ do
  assert current_account.page_templates.first.name == "new layout"
end

#TODO: dry these two steps to a helper assert method
Then /^I should see no layouts$/ do
  PageTemplate.all.each do |layout|
    assert has_no_xpath?(".//tr[@id='page_template_#{layout.id}']")
  end
end

Then /^I should see the layout was deleted$/ do
  # asserting an empty layouts table
  PageTemplate.all.each do |layout|
    assert has_no_xpath?(".//tr[@id='page_template_#{layout.id}']")
  end
end
