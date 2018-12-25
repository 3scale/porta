require 'test_helper'

class Abilities::GroupsTest < ActiveSupport::TestCase

  # REFACTOR: what about DRYing this up with other switch tests?

  def setup
    @provider = FactoryBot.create(:provider_account)
    assert @provider.settings.groups.denied?
  end

  test 'provider can manage groups' do
    user = FactoryBot.create(:user, :account => @provider, :role => :member)
    ability = Ability.new(user)

    assert_cannot ability, :admin, :groups
    assert_cannot ability, :see, :groups

    @provider.settings.allow_groups!
    assert_can ability.reload!, :see, :groups

    user.update_attribute :role, :admin
    ability.reload!

    assert_can ability, :admin, :groups
    assert_can ability, :manage, :groups
  end

  test 'buyer can manage groups' do
    buyer   = FactoryBot.create(:buyer_account, :provider_account => @provider)
    user    = FactoryBot.create(:user, :account => buyer, :role => :member)
    ability = Ability.new(user)

    assert_cannot ability, :see, :groups
    assert_cannot ability, :admin, :groups

    @provider.settings.allow_groups!
    assert_cannot ability.reload!, :see, :groups

    @provider.settings.show_groups!
    ability.reload!

    assert_can ability, :see, :groups
    assert_cannot ability, :manage, :groups
  end
end
