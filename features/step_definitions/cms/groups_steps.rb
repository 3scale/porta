
Given /^(provider "[^\"]*") has groups for buyers:$/ do |provider, table|
  table.hashes.each do |hash|
    Factory :cms_group, :name => hash['name'], :provider => provider
  end
end

Given /^(provider "[^\"]*") has no groups for buyers$/ do |provider|
  assert provider.provided_groups_for_buyers.empty?
end

Given /^(user "[^"]*") has access to the admin section "(.+?)"$/ do |user, group|
  user.member_permissions.create! :admin_section => group
end

Given /^(user "[^"]*") belongs to the (buyer group "[^"]*" of provider "[^"]*")$/ do |user, group|
  user.user_group_memberships.create! :group_id => group.id
end

Given /^(user "[^"]*") does not belong to the admin group "([^"]*)" of provider "[^"]*"$/ do |user, admin_section|
  if user.has_permission?(admin_section)
    user.admin_sections = user.admin_sections - [admin_section]
    user.save
  end
end

When /^I update a group$/ do
  visit cms_groups_path
  find(:xpath, ".//tr[@id='group_#{current_account.groups.first.id}']").click
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in "Name", :with => "new group"
  find(:xpath, ".//input[@id='group_submit']").click

  sleep 0.5
end


Then /^the group "([^\"]*)" should be created$/ do |name|
  Group.find_by_name(name).should_not be_nil
end

Then /^I should see the (buyer "[^"]*") belongs to the (buyer group "[^"]*" of provider "[^\"]*")$/ do |account, group|
  assert account.groups.include?(group)
end

Then /^I should see the (buyer "[^"]*") does not belong to the (buyer group "[^"]*" of provider "[^\"]*")$/ do |account, group|
  assert account.groups.include?(group)
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

Then /^I should see the group changed$/ do
  assert current_account.groups.first.name == "new group"
end
