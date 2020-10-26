# frozen_string_literal: true

Given "{provider} has groups for buyers" do |provider, table|
  table.hashes.each do |hash|
    FactoryBot.create :cms_group, name: hash['name'], provider: provider
  end
end

Given "{provider} has no groups for buyers" do |provider|
  assert provider.provided_groups_for_buyers.empty?
end

Given "{user} has access to the admin section {string}" do |user, group|
  user.member_permissions.create! admin_section: group
end

Given "{user} belongs to the {buyer_group_of_provider}" do |user, group|
  user.user_group_memberships.create! group_id: group.id
end

Given "{user} does not belong to the admin group {string} of provider {string}" do |user, admin_section|
  if user.has_permission?(admin_section)
    user.admin_sections = user.admin_sections - [admin_section]
    user.save
  end
end

When "I update a group" do
  visit cms_groups_path
  find(:xpath, ".//tr[@id='group_#{current_account.groups.first.id}']").click
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in 'Name', with: "new group"
  find(:xpath, ".//input[@id='group_submit']").click

  sleep 0.5
end

Then "the group {string} should be created" do |name|
  assert_not_nil Group.find_by(name: name)
end

Then "I should see the {buyer} {does}( )belong(s) to the {buyer_group_of_provider}" do |account, belongs, group|
  assert_equal belongs, account.groups.include?(group)
end

Then "I should see no groups" do
  CMS::Group.all.each do |group|
    assert has_no_xpath?(".//tr[@id='cms_group_#{group.id}']")
  end
end

Then "I should see my groups" do
  current_account.provided_groups.each do |group|
    assert has_xpath?(".//tr[@id='cms_group_#{group.id}']")
  end
end

Then "I should see the group changed" do
  assert current_account.groups.first.name == "new group"
end
