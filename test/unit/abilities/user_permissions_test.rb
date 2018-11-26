require 'test_helper'

class Abilities::UserPermissionsTest < ActiveSupport::TestCase

  def setup
    @provider = Factory.create(:simple_provider)
  end

  test 'member cannot update any user permissions' do
    member1 = Factory(:member, account: @provider)
    member2 = Factory(:member, account: @provider)
    ability = Ability.new(member1)

    assert_cannot ability, :update_permissions, member1
    assert_cannot ability, :update_permissions, member2
  end

  test "nobody can update admin's permissions" do
    admin = Factory(:admin, account: @provider)
    another_admin = Factory(:admin, account: @provider)
    ability = Ability.new(admin)

    assert_cannot ability, :update_permissions, admin
    assert_cannot ability, :update_permissions, another_admin
  end

  test "admin can update other members' permissions in the same account" do
    admin = Factory(:admin, account: @provider)
    member = Factory(:member, account: @provider)
    ability = Ability.new(admin)

    assert_can ability, :update_permissions, member
  end

  test "admin cannot update other members' permissions in other provider accounts" do
    another_provider = Factory.create(:simple_provider)
    admin = Factory(:admin, account: @provider)
    member = Factory(:member, account: another_provider)
    ability = Ability.new(admin)

    assert_cannot ability, :update_permissions, member
  end
end
