# frozen_string_literal: true

Given "{provider} has groups for buyers:" do |provider, table|
  table.hashes.each do |hash|
    FactoryBot.create :cms_group, name: hash['name'], provider: provider
  end
end

Given "{user} has access to the admin section {string}" do |user, group|
  user.member_permissions.create! admin_section: group
end

Given "{user} does not belong to the admin group {string} of provider {string}" do |user, admin_section, _provider|
  if user.has_permission?(admin_section)
    user.admin_sections = user.admin_sections - [admin_section]
    user.save
  end
end

Then /^I should see no groups$/ do
  CMS::Group.all.each do |group|
    assert has_no_xpath?(".//tr[@id='cms_group_#{group.id}']")
  end
end

Then /^I should see my groups$/ do
  current_account.provided_groups.each do |group|
    assert has_xpath?(".//tr[@id='cms_group_#{group.id}']")
  end
end
