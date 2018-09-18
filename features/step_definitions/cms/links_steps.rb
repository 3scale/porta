
Given /^(provider "[^\"]*") has no links$/ do |provider|
  assert provider.provided_groups_for_providers.empty?
end

When /^I create a bcms link/ do
  visit cms_sitemap_path
  find(:xpath, ".//td[@id='section_#{Section.root(current_account).first.id}']").click

  find(:xpath, ".//a[@id='add-link-button']").click
  fill_in "link_name", :with => "name"
  fill_in "link_url", :with => "http://www.example.net"

  find(:xpath, ".//input[@id='link_submit']").click
end

When /^I update a link$/ do
  visit cms_links_path
  find(:xpath, ".//tr[@id='link_#{current_account.links.first.id}']").click
  find(:xpath, ".//a[@id='properties-button']").click

  fill_in "Name", :with => "new link"
  fill_in "Url", :with => "http://www.new-example.net"
  find(:xpath, ".//input[@id='link_submit']").click

end

Then /^the link "([^\"]*)" should be created$/ do |name|
  Link.find_by_name(name).should_not be_nil
end

Then /^I should see no links$/ do
  Link.all.each do |link|
    assert has_no_xpath?(".//td[@id='link_#{link.id}']")
  end
end

Then /^I should see my links$/ do
  current_account.links.each do |link|
    assert has_xpath?(".//td[@id='link_#{link.id}']")
  end
end

Then /^I should see my link$/ do
  link = current_account.links.first
  assert has_xpath?(".//td[@id='link_#{link.id}']")
end

Then /^I should see the link changed$/ do
  assert current_account.links.first.name == "new link"
end
