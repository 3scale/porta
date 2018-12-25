# MT start
Given /^(provider "[^\"]*") has pages on the root section$/ do |provider|
  page = FactoryBot.create :cms_page, :provider => provider, :section => provider.sections.root
end

Given /^(provider "[^\"]*") has a page on the root section named "([^\"]*)"$/ do |provider, name|
  page = FactoryBot.create :cms_page, :provider => provider, :title => name, :section => provider.sections.root
end

Given /^(provider "[^\"]*") has no pages$/ do |provider|
   provider.pages.delete_all
end
# MT End

Given /^the page at "([^\"]*)" of (provider "[^\"]*") is public$/ do |path, provider|
  page = provider.pages.find_by_path!(path)
  page.section.public = true
  page.section.save!
end

Given /^(provider "[^\"]*") has a hidden page with the title "([^\"]*)"$/ do |provider, title|
  FactoryBot.create :hidden_page, :title => title, :account => provider
end

Given /^(provider "[^\"]*") has a draft page with the title "([^\"]*)"$/ do |provider, title|
  FactoryBot.create :page, :title => title, :account => provider
end

Given /^(provider "[^\"]*") has a published page with the title "([^\"]*)"$/ do |provider, title|
  FactoryBot.create :published_page, :title => title, :account => provider, :section => provider.provided_sections.first # HACK: hack
end

Given /^(provider "[^\"]*") has a published page with the title "([^"]*)" of section "([^"]*)"$/ do |provider, title, sec_name|
  section = provider.sections.find_by_system_name(sec_name)
  FactoryBot.create :cms_page, :title => title, :body => title, :section => section, :provider_id => provider.id, :path => "#{section.full_path}/#{title.parameterize}"
end

Given /^(provider "[^\"]*") has a published page with the title "([^"]*)" and path "([^"]*)" of section "([^"]*)"$/ do |provider, title, path, sec_name|
  section = provider.sections.find_by_system_name(sec_name)
  FactoryBot.create :cms_page, :title => title, :body => title, :section => section, :provider_id => provider.id, :path => path, :tenant_id => provider.id
end


Given /^(provider "[^\"]*") has a page at "([^"]*)" with content$/ do |provider, path, content|
  if page = provider.pages.find_by_path(path)
    page.update_attribute(:draft, content)
    page.publish!
  else
    FactoryBot.create(:cms_page, :path => path, :provider => provider, :draft => content).publish!
  end
end

Given /^provider "([^\"]*)" has a public page at "([^"]*)" with content$/ do |provider, path, string|
  step %(provider "#{provider}" has a page at "#{path}" with content), string
  step %(the page at "#{path}" of provider "#{provider}" is public)
end

Given /^there are no pages$/ do
  CMS::Page.destroy_all
end

Given /^a route "([^"]*)" of (page "[^"]*")$/ do |route, page|
  page.page_routes.create!(:name => route.gsub(/\//,'-'),
                           :pattern => route, :code => "")
end

Then /^I should see the page "([^"]*)"$/ do |page_title|
  #OPTIMIZE: what to optimize?? the what, optimize the what
  page.body.should =~ /<title>#{page_title}<\/title>/
end

Then /^going to the page "([^\"]*)" should raise "([^"]*)"$/ do |title, e|
  path = Page.find_by_title(title).path
  lambda { visit(path) }.should raise_error(e.constantize)
end

Then /^the page "([^"]*)" should exist$/ do |name|
  assert Page.find_by_name(name)
end

Then /^I should see my pages on root section$/ do
  current_account.pages.each do |page|
    assert has_xpath?(".//td[@id='page_#{page.id}']")
  end
end

Then /^I should see my page$/ do
  p = current_account.pages.first
  assert has_xpath?(".//td[@id='page_#{p.id}']")
end

Then /^the page "([^\"]*)" should be created$/ do |name|
  Page.find_by_name(name).should_not be_nil
end

Then /^I should see no pages$/ do
  Page.all.each do |page|
    assert has_no_xpath?(".//tr[@id='page_#{page.id}']")
  end
end
