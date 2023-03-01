# frozen_string_literal: true

Given "{provider} has section {string}" do |provider, title|
  section = FactoryBot.create :cms_section, :provider => provider, :title => title, :system_name => title, :parent => provider.sections.first
end

# Given /^(provider "[^\"]*") has a public section "([^"]*)"$/ do |provider, name|
#   FactoryBot.create :section, :name => name, :account => provider
# end

# Given /^(provider "[^\"]*") has a private section "([^"]*)"$/ do |provider, name|
#   FactoryBot.create :cms_section, :name => name, :public => false, :account => provider
# end

Given "{provider} has a {word} section {string}" do |provider, protection, name|
  add_section_to_provider(provider, protection, name)
end

Given "{provider} has a {word} section {string} with path {string}" do |provider, protection, name, path|
  add_section_to_provider(provider, protection, name, path)
end

def add_section_to_provider(provider, protection, name, path = nil)
  root = provider.sections.root || FactoryBot.create(:root_cms_section, provider: provider)

  options = {:title => name,
    :system_name => name,
    :provider => provider,
    :parent => root,
    :public => (protection == 'public')}

  options.merge(path ? {:path => path} : {})

  provider.sections.create!(options)
end

Given "the {section_of_provider} is access restricted" do |section|
  section.update_attributes({ :public => false })
end

#TODO: use test_helper TestHelpers::SectionsPermissions
Given "the buyer {string} has access to the section {string} of {provider}" do |account, section_name, provider|
  account = provider.buyer_accounts.find_by_org_name!(account)
  section = provider.sections.find_by_system_name!(section_name)
  group = provider.provided_groups.create!(:name => "#{account.org_name}_#{rand}")

  # TODO: Rails 3.1:
  # * use group.sections << section
  # * use account.groups << group
  group.group_sections.create! :section => section
  account.permissions.create! :group => group
end

When /^I update "(.+?)" section title to "(.+?)"$/ do |section_system_name, title|
  visit edit_provider_admin_cms_section_path(CMS::Section.find_by_system_name(section_system_name).id)
  fill_in "Title", :with => title
  click_button "Update"
end

Then "the {section_of_provider} should be access restricted" do |section|
  assert !section.public?
end
