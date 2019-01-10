Given /^(provider "[^\"]*") has redirects$/ do |provider|
  FactoryBot.create :redirect, :account => provider
end



When /^I create a bcms redirect$/ do
  visit cms_redirects_path
  find(:xpath, ".//a[@href='/cms/redirects/new']").click
  fill_in "From", :with => "/from"
  fill_in "To", :with => "/to"
  find(:xpath, ".//input[@id='redirect_submit']").click
end

When /^I update a redirect$/ do
  visit cms_redirects_path
  find(:xpath, ".//tr[@id='redirect_#{Redirect.first.id}']").click
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in "From", :with => "/new_from"
  fill_in "To", :with => "/new_to"
  find(:xpath, ".//input[@id='redirect_submit']").click

  sleep(0.5)
end

When /^I delete a redirect$/ do
  visit cms_redirects_path
  find(:xpath, ".//tr[@id='redirect_#{Redirect.first.id}']").click
  find(:xpath, ".//a[@id='delete_button']").click

  sleep(0.5)
end


Then /^I should see my redirects$/ do
  current_account.redirects.each do |r|
    assert has_xpath?(".//tr[@id='redirect_#{r.id}']")
  end
end

Then /^I should see the redirect changed$/ do
  r = current_account.redirects.first

  assert "/new_from" == r.from_path
  assert "/new_to" == r.to_path
end

#TODO: dry these two steps to a helper assert method
Then /^I should see no redirects$/ do
  Redirect.all.each do |r|
    assert has_no_xpath?(".//tr[@id='redirect_#{r.id}']")
  end
end

Then /^I should see the redirect was deleted$/ do
  # asserting an empty redirects table
  Redirect.all.each do |r|
    assert has_no_xpath?(".//tr[@id='redirect_#{r.id}']")
  end
end
