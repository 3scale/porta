# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Abilities::BuyersTest < ActiveSupport::TestCase

  def setup
    @provider = Factory(:provider_account)
    @buyer    = Factory(:buyer_account, :provider_account => @provider)
    @not_admin = Factory(:user, :account => @buyer, :role => :member)
  end

  test 'provider admin can read, update and destroy buyer accounts' do
    ability = Ability.new(@provider.admins.first)

    assert_can ability, :read, @provider => Account
    assert_can ability, :read, @buyer

    assert_can ability, :update, @buyer
    assert_can ability, :destroy, @buyer
  end

  test 'provider admin can reject and approve buyer accounts' do
    ability = Ability.new(@provider.admins.first)

    assert_can ability, :approve, @buyer
    assert_can ability, :reject, @buyer
  end

  test 'provider members can read buyer accounts' do
    ability = Ability.new(Factory(:user, :account => @provider))

    assert_can ability, :read, @provider => Account
    assert_can ability, :read, @buyer
  end

  test 'provider members can\'t create/update/destroy buyer accounts' do
    ability = Ability.new(Factory(:user, :account => @provider))

    assert_cannot ability, :create, @provider => Account
    assert_cannot ability, :update,  @buyer
    assert_cannot ability, :destroy,  @buyer
  end

  test 'provider members can\'t reject nor approve buyer accounts' do
    ability = Ability.new(Factory(:user, :account => @provider))

    assert_cannot ability, :approve,  @buyer
    assert_cannot ability, :reject,  @buyer
  end

  test 'provider admin can\'t configure buyer accounts' do
    assert_cannot Ability.new(@provider.admins.first), :configure, @buyer
  end

  test 'superadmin can configure provider accounts' do
    assert_can Ability.new(Account.master.admins.first), :configure, @provider
  end

  test 'provider admin can manage his buyer users' do
    ability = Ability.new(@provider.admins.first)
    assert ability.can?(:read, @buyer => User)
    user = @buyer.users.first

    assert_can ability, :read, user
    assert_can ability, :update, user
    assert_can ability, :destroy, user
    assert_can ability, :suspend, user
    assert_can ability, :unsuspend, user
    assert_cannot ability, :activate, user
  end

  test 'provider admin can update role of his buyer users' do
    admin = @provider.admins.first
    buyer_user = Factory(:user, :account => @buyer)
    assert_can Ability.new(admin), :update_role, buyer_user
  end

  test 'provider admin can\'t update role of a buyer user if that user is the only admin of his account' do
    @buyer.users.first.update_attribute(:role, :admin)
    @buyer.users[1..-1].each { |user| user.update_attribute(:role, :member) }
    assert_cannot Ability.new( @provider.admins.first), :update_role, @buyer.users.first
  end

  test 'provider admin can\'t impersonate buyer users' do
    assert_cannot Ability.new( @provider.admins.first), :impersonate, @buyer.users.first
  end

  test 'provider admin can\'t impersonate other provider users' do
    other_provider = Factory(:provider_account)
    assert_cannot Ability.new( @provider.admins.first), :impersonate, other_provider.users.first
  end

  test 'buyer can update their user details' do
    user = @buyer.admins.first
    assert_can Ability.new(user), :update, user
  end

  test 'non admin buyer can update their user details' do
    assert_can Ability.new(@not_admin), :update, @not_admin
  end

  test 'buyer cant update their user details if useraccountarea disabled' do
    @provider.settings.update_attribute(:useraccountarea_enabled, false)
    user = @buyer.admins.first
    assert_cannot Ability.new(user), :update, user
  end

  test 'provider can always update their user details' do
    provider_user = @provider.admins.first
    ability = Ability.new(provider_user)

    @provider.settings.update_attribute(:useraccountarea_enabled, true)
    assert_can ability, :update, provider_user

    @provider.settings.update_attribute(:useraccountarea_enabled, false)
    assert_can ability, :update, provider_user
  end

  test 'buyers can manage alerts if they are enable in cinstance' do
    cinstance = Factory(:cinstance, :name => 'cde', :user_account => @buyer)
    ability = Ability.new(@buyer.admins.first)

    cinstance.stubs(:buyer_alerts_enabled?).returns(false)
    assert_cannot ability, :manage_alerts, cinstance

    cinstance.stubs(:buyer_alerts_enabled?).returns(true)
    assert_can ability, :manage_alerts, cinstance
  end

end
