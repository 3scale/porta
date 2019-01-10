require 'test_helper'

class Abilities::ImpersonateTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create :provider_account
  end

  test "master admin cannot impersonate provider accounts without 3scale admin user" do
    user = Account.master.admins.first
    assert_cannot Ability.new(user), :impersonate, @provider
  end

  test "master admin can impersonate provider accounts" do
    @provider.admins.first.update_attribute :username, ThreeScale.config.impersonation_admin['username']
    @provider.reload

    user = Account.master.admins.first
    assert_can Ability.new(user), :impersonate, @provider
  end

  test "provider admin users cannot impersonate" do
    @provider.admins.first.update_attribute :username, ThreeScale.config.impersonation_admin['username']
    @provider.reload

    assert_cannot Ability.new(@provider.admins.first), :impersonate, @provider
  end
end
