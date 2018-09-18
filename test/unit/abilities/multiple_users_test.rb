require 'test_helper'

class Abilities::MultipleUsersTest < ActiveSupport::TestCase

  # REFACTOR: what about DRYing this up with other switch tests?

  def setup
    @provider = Factory(:provider_account)
    assert @provider.settings.multiple_users.denied?
  end

  test 'provider can manage multiple users' do
    user = Factory(:user, :account => @provider, :role => :member)
    ability = Ability.new(user)

    assert_cannot ability, :see, :multiple_users
    assert_cannot ability, :admin, :multiple_users

    @provider.settings.allow_multiple_users!
    ability.reload!

    assert_can ability, :see, :multiple_users
    assert_cannot ability, :admin, :multiple_users

    user.member_permissions.create!(:admin_section => 'partners')

    ability.reload!
    assert_can ability, :admin, :multiple_users

    user.update_attribute :role, :admin
    ability.reload!

    assert_can ability, :manage, :multiple_users
  end

  test 'buyer can manage multiple users' do
    buyer   = Factory(:buyer_account, :provider_account => @provider)
    user    = Factory(:user, :account => buyer, :role => :member)
    ability = Ability.new(user)

    assert_cannot ability, :see, :multiple_users
    assert_cannot ability, :admin, :multiple_users

    @provider.settings.allow_multiple_users!
    assert_cannot ability.reload!, :see, :multiple_users

    @provider.settings.show_multiple_users!
    ability.reload!

    assert_can ability, :see, :multiple_users
    assert_cannot ability, :manage, :multiple_users
  end
end
