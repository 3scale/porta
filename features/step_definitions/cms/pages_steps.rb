# frozen_string_literal: true

Given "{provider} has a published page with the title {string} of section {string}" do |provider, title, sec_name|
  section = provider.sections.find_by_system_name(sec_name)
  FactoryBot.create :cms_page, :title => title, :body => title, :section => section, :provider_id => provider.id, :path => "#{section.full_path}/#{title.parameterize}"
end

Given "{provider} has a published page with the title {string} and path {string} of section {string}" do |provider, title, path, sec_name|
  section = provider.sections.find_by_system_name(sec_name)
  FactoryBot.create :cms_page, :title => title, :body => title, :section => section, :provider_id => provider.id, :path => path, :tenant_id => provider.id
end

Given "{provider} has a public page at {string} with content" do |provider, path, content|
  if page = provider.pages.find_by_path(path)
    page.update_attribute(:draft, content)
  else
    page = FactoryBot.create(:cms_page, :path => path, :provider => provider, :draft => content)
  end

  page.publish!
  page.section.public = true
  page.section.save!
end

Given /^there are no pages$/ do
  CMS::Page.destroy_all
end
