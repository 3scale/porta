Given /^(provider "[^\"]*") has portlets$/ do |provider|
  FactoryBot.create :blog_post_portlet, :account => provider
end

Given /^(provider "[^\"]*") has no portlets$/ do |provider|
  assert provider.portlets.empty?
end


Given /^(provider "[^\"]*") has the blog posts portlet is connected to "([^"]*)" container in (page "[^"]*")$/ do |provider, container, page|
  blog = FactoryBot.create :blog

  BlogPostsPortlet.create!(:name => "Articles Portlet", :blog_id => blog.id,
                           :template => BlogPostsPortlet.default_template,
                           :connect_to_page_id => page.id,
                           :connect_to_container => "main",
                           :publish_on_save => true, :account => provider)
end


When /^I create a bcms portlet$/ do
  visit cms_portlets_path
  find(:xpath, ".//a[@id='add_button']").click
  # clicking first portlet type of the list
  find(:xpath, ".//form[@id='new_portlet']/div/a").click

  fill_in "Name", :with => "portlet name"
  find(:xpath, ".//input[@name='commit']").click
end

When /^I disconnect the blog posts portlet from the container$/ do
  connector = BlogPostsPortlet.last.connectors
    .find(:first, :conditions => { :page_id => Page.first.id })

  bypass_confirm_dialog

  within(:xpath, "//div[@id='connector_#{connector.id}']") do
    find(:xpath, ".//a[@class='confirm_with_title http_delete']").click
  end
end

When /^I save the portlet$/ do
  click_button "Save"
end

When /^I update a portlet$/ do
  visit cms_portlets_path
  find(:xpath, ".//tr[@id='blog_post_portlet_#{current_account.portlets.first.id}']").click
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in "Name", :with => "new portlet name"
  find(:xpath, ".//input[@name='commit']").click

  sleep 0.5
end

When /^I delete a portlet$/ do
  visit cms_portlets_path

  portlet = current_account.portlets.first
  portlet_type = portlet.type.underscore

  find(:xpath, ".//tr[@id='#{portlet_type}_#{portlet.id}']").click
  find(:xpath, ".//a[@id='delete_button']").click

  sleep(0.5)
end


Then /^I should see the blog posts portlet was removed from the container$/ do
  assert has_content?("Removed '#{BlogPostsPortlet.last.name}' from the 'main' container")

  connector = BlogPostsPortlet.last.connectors
    .find(:first, :conditions => { :page_id => Page.first.id })

  #OPTIMIZE: the bcms page with buttons could be improved to make this assertion more strict
  assert has_no_xpath?("//div[@id='connector_#{connector.id}']")
end

Then /^I should see the portlet content$/ do
  #improve this assertion
  assert has_content?("Used on")
end

Then /^I should see no portlets$/ do
  Portlet.all.each do |portlet|
    assert has_no_xpath?(".//tr[@id='#{portlet.type.underscore}_#{portlet.id}']")
  end
end

Then /^I should see my portlets$/ do
  current_account.portlets.each do |portlet|
    assert has_xpath?(".//tr[@id='#{portlet.type.underscore}_#{portlet.id}']")
  end
end

Then /^I should see the portlet$/ do
  assert has_xpath?(".//div", "Block contents:")
  #we want to get rid of this strange portlet behaviour
  # assert has_no_xpath?(".//div[@class='content']", /ERROR/)
end

#FIXME: capybara fails to load this page Capybara::Driver::Webkit::WebkitInvalidResponseError
Then /^I should see the portlet changed$/ do
  assert current_account.portlets.first.name == "new portlet name"
end

Then /^I should see the portlet was deleted$/ do
  # asserting an empty portlets table
  Portlet.all.each do |portlet|
    portlet_type = portlet.type.underscore
    assert has_no_xpath?(".//tr[@id='#{portlet_type}_#{portlet.id}']")
  end
end

