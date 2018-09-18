
Given /^(provider "[^\"]*") has section "(.+?)"$/ do |provider, title|
  section = Factory :cms_section, :provider => provider, :title => title, :system_name => title, :parent => provider.sections.first
end

# Given /^(provider "[^\"]*") has a public section "([^"]*)"$/ do |provider, name|
#   Factory :section, :name => name, :account => provider
# end

# Given /^(provider "[^\"]*") has a private section "([^"]*)"$/ do |provider, name|
#   Factory :cms_section, :name => name, :public => false, :account => provider
# end

Given /^(provider "[^\"]*") has a (public|private|restricted) section "([^"]*)"(?: with path "([^"]*)")?$/ do |provider, protection, name, path|
  root = provider.sections.root || Factory(:root_cms_section, :account => provider)

  options = {:title => name,
    :system_name => name,
    :account => provider,
    :parent => root,
    :public => (protection == 'public')}

  options.merge(path ? {:path => path} : {})

  provider.sections.create!(options)
end

Given /^the (section "[^\"]*" of provider "[^\"]*") is access restricted$/ do |section|
  section.update_attributes({ :public => false })
end

#TODO: use test_helper TestHelpers::SectionsPermissions
Given /^the buyer "(.+?)" has access to the section "(.+?)" of (provider ".+?")$/ do |account, section_name, provider|
  account = provider.buyer_accounts.find_by_org_name!(account)
  section = provider.sections.find_by_system_name!(section_name)
  group = provider.provided_groups.create!(:name => "#{account.org_name}_#{rand}")

  # TODO: Rails 3.1:
  # * use group.sections << section
  # * use account.groups << group
  group.group_sections.create! :section => section
  account.permissions.create! :group => group
end


When /^I click the (section "[^\"]*" of provider "[^\"]*")$/ do |section|
  find(:xpath, "//td[@id='section_#{section.id}']").click
end

When /^I create the root section$/ do
  visit cms_sections_path
  click_button "Create Root Section"
end

When /^I update "(.+?)" section title to "(.+?)"$/ do |section_system_name, title|
  visit edit_provider_admin_cms_section_path(CMS::Section.find_by_system_name(section_system_name).id)
  fill_in "Title", :with => title
  click_button "Update"
end

Then /^the (section "[^\"]*" of provider "[^\"]*") should be access restricted$/ do |section|
  assert !section.public?
end

#TODO: dry these two steps to a helper assert method
Then /^I should see no section$/ do
  Section.all.each do |section|
    assert has_no_xpath?(".//td[@id='section_#{section.id}']")
  end
end

Then /^I should see my sections$/ do
  current_account.provided_sections.each do |section|
    assert has_xpath?(".//td[@id='section_#{section.id}']")
  end
end

Then /^I should see my root section$/ do
  root_section_id = Section.root(current_account.id).first.id
  assert has_xpath?(".//td[@id='section_#{root_section_id}']")
  # just to differentiate it from a normal section
  assert has_xpath?(".//ul[@id='root_#{root_section_id}']")
end

Then /^I should see my section$/ do
  section = current_account.provided_sections.last
  assert has_xpath?(".//td[@id='section_#{section.id}']")
end

Then /^I should see my section changed$/ do
  section = current_account.provided_sections.last
  assert has_xpath?(".//td[@id='section_#{section.id}']")
  #check that it effectively changed
end
