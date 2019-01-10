Given /^(provider "[^\"]*") has page partials$/ do |provider|
  FactoryBot.create :page_partial, :account => provider
end


Given /^the partial "([^\"]*)" of (provider "[^\"]*") is$/ do |name, provider, body|
  FactoryBot.create(:cms_partial, :system_name => name, :provider => provider, :draft => body).publish!
end

When /^I create a bcms page partial$/ do
  visit cms_page_partials_path
  click_link "Add"

  fill_in "Name", :with => "name"

  find(:xpath, ".//input[@id='page_partial_submit']").click
end

When /^I update a page partial$/ do
  visit cms_page_partials_path
  find(:xpath, ".//tr[@id='page_partial_#{current_account.page_partials.first.id}']").click
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in "Name", :with => "new page partial"
  find(:xpath, ".//input[@id='page_partial_submit']").click

  sleep 0.5
end

When /^I delete a page partial$/ do
  visit cms_page_partials_path
  find(:xpath, ".//tr[@id='page_partial_#{current_account.page_partials.first.id}']").click
  find(:xpath, ".//a[@id='delete_button']").click

  sleep(0.5)
end


Then /^I should see my page partials$/ do
  current_account.page_partials.each do |partial|
    assert has_xpath?(".//tr[@id='page_partial_#{partial.id}']")
  end
end

Then /^I should see my page partial$/ do
  partial = current_account.page_partials.first
  assert has_xpath?(".//tr[@id='page_partial_#{partial.id}']")
end

Then /^I should see the page partial changed$/ do
  assert current_account.page_partials.first.name == "new page partial"
end

#TODO: dry these two steps to a helper assert method
Then /^I should see no page partials$/ do
  PageTemplate.all.each do |partial|
    assert has_no_xpath?(".//tr[@id='page_partial_#{partial.id}']")
  end
end

Then /^I should see the page partial was deleted$/ do
  # asserting an empty page partials table
  PageTemplate.all.each do |partial|
    assert has_no_xpath?(".//tr[@id='page_partial_#{partial.id}']")
  end
end
