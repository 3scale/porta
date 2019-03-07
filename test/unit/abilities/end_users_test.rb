require 'test_helper'

class Abilities::EndUsersTest < ActiveSupport::TestCase

  # REFACTOR: what about DRYing this up with other switch tests?

  def setup
    @provider = FactoryBot.create(:provider_account)
    assert @provider.settings.end_users.denied?
    ThreeScale.config.stubs(onpremises: false)
  end

  test 'provider can manage end users' do
    user = FactoryBot.create(:user, :account => @provider, :role => :member)
    ability = Ability.new(user)

    assert_cannot ability, :see, :end_users
    assert_cannot ability, :admin, :end_users

    @provider.settings.allow_end_users!
    ability.reload!

    assert_can ability, :see, :end_users
    assert_cannot ability, :admin, :end_users

    user.update_attribute :role, :admin
    ability.reload!

    assert_can ability, :manage, :end_users
  end

  test 'buyer can manage end users' do
    buyer   = FactoryBot.create(:buyer_account, :provider_account => @provider)
    user    = FactoryBot.create(:user, :account => buyer, :role => :member)
    ability = Ability.new(user)

    assert_cannot ability, :see, :end_users
    assert_cannot ability, :admin, :end_users

    @provider.settings.allow_end_users!
    assert_cannot ability.reload!, :see, :end_users

    @provider.settings.show_end_users!
    ability.reload!

    assert_can ability, :see, :end_users
    assert_cannot ability, :manage, :end_users
  end

  class Onpremises < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
      ThreeScale.config.stubs(onpremises: true)
    end

    test 'provider cannot manage end users' do
      user = FactoryBot.create(:user, :account => @provider, :role => :member)
      ability = Ability.new(user)

      assert_cannot ability, :see, :end_users
      assert_cannot ability, :admin, :end_users

      @provider.settings.allow_end_users!
      ability.reload!

      assert_cannot ability, :see, :end_users
      assert_cannot ability, :admin, :end_users

      user.update_attribute :role, :admin
      ability.reload!

      assert_cannot ability, :manage, :end_users
    end

    test 'buyer cannot manage end users' do
      buyer   = FactoryBot.create(:buyer_account, :provider_account => @provider)
      user    = FactoryBot.create(:user, :account => buyer, :role => :member)
      ability = Ability.new(user)

      assert_cannot ability, :see, :end_users
      assert_cannot ability, :admin, :end_users

      @provider.settings.allow_end_users!
      assert_cannot ability.reload!, :see, :end_users

      @provider.settings.show_end_users!
      ability.reload!

      assert_cannot ability, :see, :end_users
      assert_cannot ability, :manage, :end_users
    end
  end
end
