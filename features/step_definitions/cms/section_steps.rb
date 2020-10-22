# frozen_string_literal: true

Given "{provider} has section {string}" do |provider, title|
  FactoryBot.create :cms_section, provider: provider,
                                  title: title,
                                  system_name: title,
                                  parent: provider.sections.first
end

# Given "{provider} has a public section "([^"]*)"$/ do |provider, name|
#   FactoryBot.create :section, name: name, account: provider
# end

# Given "{provider} has a private section "([^"]*)"$/ do |provider, name|
#   FactoryBot.create :cms_section, name: name, :public => false, account: provider
# end

Given "{provider} has a {public} section {string}( with path {string})" do |provider, public, name, path|
  root = provider.sections.root || FactoryBot.create(:root_cms_section, account: provider)

  options = { title: name,
              system_name: name,
              account: provider,
              parent: root,
              public: public }

  options.merge(path ? {path: path} : {})

  provider.sections.create!(options)
end

Given "the {section_of_provider} is access restricted" do |section|
  section.update!(public: false)
end

#TODO: use test_helper TestHelpers::SectionsPermissions
Given "the buyer {string} has access to the section {string} of {provider}" do |account, section_name, provider|
  account = provider.buyer_accounts.find_by!(org_name: account)
  section = provider.sections.find_by!(system_name: section_name)
  group = provider.provided_groups.create!(name: "#{account.org_name}_#{rand}")

  # TODO: Rails 3.1:
  # * use group.sections << section
  # * use account.groups << group
  group.group_sections.create! section: section
  account.permissions.create! group: group
end

When "I click the {section_of_provider}" do |section|
  find(:xpath, "//td[@id='section_#{section.id}']").click
end

When "I create the root section" do
  visit cms_sections_path
  click_button 'Create Root Section'
end

When "I update {string} section title to {string}" do |section_system_name, title|
  visit edit_provider_admin_cms_section_path(CMS::Section.find_by!(system_name: section_system_name).id)
  fill_in 'Title', with: title
  click_button 'Update'
end

Then "the {section_of_provider} should be access restricted" do |section|
  assert !section.public?
end

Then "I should see no section(s)" do
  Section.all.each do |section|
    assert has_no_xpath?(".//td[@id='section_#{section.id}']")
  end
end

Then "I should see my sections" do
  current_account.provided_sections.each do |section|
    assert has_xpath?(".//td[@id='section_#{section.id}']")
  end
end

Then "I should see my root section" do
  root_section_id = Section.root(current_account.id).first.id
  assert has_xpath?(".//td[@id='section_#{root_section_id}']")
  # just to differentiate it from a normal section
  assert has_xpath?(".//ul[@id='root_#{root_section_id}']")
end

Then "I should see my section" do
  section = current_account.provided_sections.last
  assert has_xpath?(".//td[@id='section_#{section.id}']")
end

Then "I should see my section changed" do
  binding.pry
  # TODO: check that it effectively changed
  section = current_account.provided_sections.last
  assert has_xpath?(".//td[@id='section_#{section.id}']")
end
