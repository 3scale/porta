Given /^(provider "[^\"]*") has tags$/ do |provider|
  Factory :tag, :account => provider
end

Given /^(provider "[^\"]*") has the tag "lorem"$/ do |provider|
  Factory :tag, :account => provider, :name => "lorem"
end



When /^I create a bcms tag$/ do
  visit cms_tags_path
  find(:xpath, ".//a[@id='add_button']").click

  fill_in "Name", :with => "name"

  find(:xpath, ".//input[@id='tag_submit']").click
end

When /^I update a tag$/ do
  visit cms_tags_path
  find(:xpath, ".//tr[@id='tag_#{current_account.tags.first.id}']").click
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in "Name", :with => "new tag"
  find(:xpath, ".//input[@id='tag_submit']").click

  sleep 0.5
end

When /^I delete a tag$/ do
  visit cms_tags_path
  find(:xpath, ".//tr[@id='tag_#{current_account.tags.first.id}']").click
  find(:xpath, ".//a[@id='delete_button']").click

  sleep(0.5)
end


Then /^I should see my tags$/ do
  current_account.tags.each do |tag|
    assert has_xpath?(".//tr[@id='tag_#{tag.id}']")
  end
end

Then /^I should see my tag$/ do
  tag = current_account.tags.first
  # see the class='"dividers"' !
  assert has_xpath?(".//tr[@id='tag_#{tag.id}']//td[@class='name']/div[@class='\"dividers\"']",
                    /#{tag.name}/)
end

Then /^I should see the tag changed$/ do
  assert current_account.tags.first.name == "new tag"
end

#TODO: dry these two steps to a helper assert method
Then /^I should see no tags$/ do
  Tag.all.each do |tag|
    assert has_no_xpath?(".//tr[@id='tag_#{tag.id}']")
  end
end

Then /^I should see the tag was deleted$/ do
  # asserting an empty tags table
  Tag.all.each do |tag|
    assert has_no_xpath?(".//tr[@id='tag_#{tag.id}']")
  end
end
