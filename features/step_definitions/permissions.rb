# frozen_string_literal: true

Given "the default set of permissions is created" do
end

Given "the following groups are created:" do | groups |
  groups.hashes.each do | hash |
    permissions = Permission.find(:all, conditions: {name: hash['permissions'].split(",")})
    FactoryBot.create(:group, name: hash['name'],
                              group_type: GroupType.find_by!(name: "Member"),
                              permissions: permissions)
  end
end

Then "finance should show in the permissions list" do
  assert has_xpath?("//label", text: "Permission to be able to manage Finance")
end

Then "finance should not show in the permissions list" do
  assert has_no_xpath?("//label", text: "Permission to be able to manage Finance")
end
