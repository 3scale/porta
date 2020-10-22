# frozen_string_literal: true

# MT start
Given "{provider} has pages on the root section" do |provider|
  FactoryBot.create :cms_page, provider: provider, section: provider.sections.root
end

Given "{provider} has a page on the root section named {string}" do |provider, name|
  FactoryBot.create :cms_page, provider: provider, title: name, section: provider.sections.root
end

Given "{provider} has no pages" do |provider|
  provider.pages.delete_all
end
# MT End

Given "the page at {string} of {provider} is public" do |path, provider|
  page = provider.pages.find_by!(path: path)
  page.section.public = true
  page.section.save!
end

Given "{provider} has a hidden page with the title {string}" do |provider, title|
  FactoryBot.create :hidden_page, title: title, account: provider
end

Given "{provider} has a draft page with the title {string}" do |provider, title|
  FactoryBot.create :page, title: title, account: provider
end

Given "{provider} has a published page with the title {string}" do |provider, title|
  FactoryBot.create :published_page, title: title, account: provider, section: provider.provided_sections.first # HACK: hack
end

Given "{provider} has a published page with the title {string} of section {string}" do |provider, title, sec_name|
  section = provider.sections.find_by!(system_name: sec_name)
  FactoryBot.create :cms_page, title: title, body: title, section: section, provider_id: provider.id, path: "#{section.full_path}/#{title.parameterize}"
end

Given "{provider} has a published page with the title {string} and path {string} of section {string}" do |provider, title, path, sec_name|
  section = provider.sections.find_by!(system_name: sec_name)
  FactoryBot.create :cms_page, title: title, body: title, section: section, provider_id: provider.id, path: path, tenant_id: provider.id
end

Given "{provider} has a page at {string} with content" do |provider, path, content|
  if (page = provider.pages.find_by(path: path))
    page.update!(draft: content)
    page.publish!
  else
    FactoryBot.create(:cms_page, path: path, provider: provider, draft: content).publish!
  end
end

Given "{provider} has a public page at {string} with content" do |provider, path, string|
  step %(provider "#{provider}" has a page at "#{path}" with content), string
  step %(the page at "#{path}" of provider "#{provider}" is public)
end

Given "there are no pages" do
  CMS::Page.destroy_all
end

Given "a route {string} of {page}" do |route, page|
  page.page_routes.create!(name: route.gsub(%r{/\//},'-'), pattern: route, code: '')
end

Then "I should see the page {string}" do |page_title|
  #OPTIMIZE: what to optimize?? the what, optimize the what
  page.body.should =~ %r{/<title>#{page_title}<\/title>/}
end

Then "going to the page {string} should raise {string}" do |title, e|
  path = Page.find_by!(title: title).path
  -> { visit(path) }.should raise_error(e.constantize)
end

Then "the page {string} should exist" do |name|
  assert Page.find_by(name: name)
end

Then "I should see my pages on root section" do
  current_account.pages.each do |page|
    assert has_xpath?(".//td[@id='page_#{page.id}']")
  end
end

Then "I should see my page" do
  p = current_account.pages.first
  assert has_xpath?(".//td[@id='page_#{p.id}']")
end

Then "the page {string} should be created" do |name|
  assert_not_nil Page.find_by(name: name)
end

Then "I should see no pages" do
  Page.all.each do |page|
    assert has_no_xpath?(".//tr[@id='page_#{page.id}']")
  end
end
