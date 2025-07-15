# frozen_string_literal: true

# Create CMS groups in bulk for a provider account.
#
# And the provider has the following CMS groups:
#   | Name        |
#   | BuyerGroup1 |
#
Given "{provider} has the following CMS groups:" do |provider, table|
  parameterize_headers(table)
  table.hashes.each do |hash|
    FactoryBot.create(:cms_group, name: hash['name'], provider: provider)
  end
end

Given "{provider} has no CMS groups" do |provider|
  provider.provided_groups.destroy_all
  assert_empty provider.provided_groups
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

Then "all groups should be unchecked" do
  assert_not find_all('#groups input.pf-c-check__input').map(&:checked?).any?
end
