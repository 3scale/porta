require 'test_helper'

class Abilities::UserPermissionsTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  test 'member cannot update any user permissions' do
    members = FactoryBot.create_list(:member, 2, account: @provider)
    ability = Ability.new(members.first)

    members.each { |member| assert_cannot ability, :update_permissions, member }
  end

  test "nobody can update admin's permissions" do
    admin = FactoryBot.create(:admin, account: @provider)
    another_admin = FactoryBot.create(:admin, account: @provider)
    ability = Ability.new(admin)

    assert_cannot ability, :update_permissions, admin
    assert_cannot ability, :update_permissions, another_admin
  end

  test "admin can update other members' permissions in the same account" do
    admin = FactoryBot.create(:admin, account: @provider)
    member = FactoryBot.create(:member, account: @provider)
    ability = Ability.new(admin)

    assert_can ability, :update_permissions, member
  end

  test "admin cannot update other members' permissions in other provider accounts" do
    another_provider = FactoryBot.create(:simple_provider)
    admin = FactoryBot.create(:admin, account: @provider)
    member = FactoryBot.create(:member, account: another_provider)
    ability = Ability.new(admin)

    assert_cannot ability, :update_permissions, member
  end
end
